#
# List of events the contract logs
# Withdrawal address used always in _from and _to as it's unique
# and validator index is removed after some events
#
Deposit: event({_from: indexed(address), _validator_index: indexed(int128), _validation_address: address, _start_dyn: int128, _amount: int128(wei)})
Vote: event({_from: indexed(address), _validator_index: indexed(int128), _target_hash: indexed(bytes32), _target_epoch: int128, _source_epoch: int128})
Logout: event({_from: indexed(address), _validator_index: indexed(int128), _end_dyn: int128})
Withdraw: event({_to: indexed(address), _validator_index: indexed(int128), _amount: int128(wei)})
Slash: event({_from: indexed(address), _offender: indexed(address), _offender_index: indexed(int128), _bounty: int128(wei), _destroyed: int128(wei)})
Epoch: event({_number: indexed(int128), _checkpoint_hash: indexed(bytes32), _is_justified: bool, _is_finalized: bool})

validators: public({
    # Used to determine the amount of wei the validator holds. To get the actual
    # amount of wei, multiply this by the deposit_scale_factor.
    deposit: decimal(wei/m),
    # The dynasty the validator is joining
    start_dynasty: int128,
    # The dynasty the validator is leaving
    end_dynasty: int128,
    # The address which the validator's signatures must verify to (to be later replaced with validation code)
    addr: address,
    # The address to withdraw to
    withdrawal_addr: address
}[int128])

# Historical checkpoint hashes
checkpoint_hashes: public(bytes32[int128])

# Number of validators
next_validator_index: public(int128)

# Mapping of validator's signature address to their index number
validator_indexes: public(int128[address])

# The current dynasty (validator set changes between dynasties)
dynasty: public(int128)

# Map of the change to total deposits for specific dynasty
dynasty_wei_delta: public(decimal(wei / m)[int128])

# Total deposits in the current dynasty
total_curdyn_deposits: decimal(wei / m)

# Total deposits in the previous dynasty
total_prevdyn_deposits: decimal(wei / m)

# Mapping of dynasty to start epoch of that dynasty
dynasty_start_epoch: public(int128[int128])

# Mapping of epoch to what dynasty it is
dynasty_in_epoch: public(int128[int128])

votes: public({
    # How many votes are there for this source epoch from the current dynasty
    cur_dyn_votes: decimal(wei / m)[int128],
    # From the previous dynasty
    prev_dyn_votes: decimal(wei / m)[int128],
    # Bitmap of which validator IDs have already voted
    vote_bitmap: uint256[int128],
    # Is a vote referencing the given epoch justified?
    is_justified: bool,
    # Is a vote referencing the given epoch finalized?
    is_finalized: bool
}[int128])  # index: target epoch

# Is the current expected hash justified
main_hash_justified: public(bool)

# Value used to calculate the per-epoch fee that validators should be charged
deposit_scale_factor: public(decimal(m)[int128])

last_nonvoter_rescale: public(decimal)
last_voter_rescale: public(decimal)

current_epoch: public(int128)
last_finalized_epoch: public(int128)
last_justified_epoch: public(int128)

# Reward for voting as fraction of deposit size
reward_factor: public(decimal)

# Expected source epoch for a vote
expected_source_epoch: public(int128)

# Total deposits destroyed
total_destroyed: wei_value


# ***** Parameters *****

# Length of an epoch in blocks
EPOCH_LENGTH: public(int128)

# Withdrawal delay in blocks
WITHDRAWAL_DELAY: public(int128)

# Logout delay in dynasties
DYNASTY_LOGOUT_DELAY: public(int128)

# [backdoor] Can withdraw destroyed deposits
OWNER: address

# Sighash calculator library address
SIGHASHER: address

# Purity checker library address
PURITY_CHECKER: address

BASE_INTEREST_FACTOR: public(decimal)
BASE_PENALTY_FACTOR: public(decimal)

# Minimum deposit size if no one else is validating
MIN_DEPOSIT_SIZE: wei_value

# Huge integer to be used for default end_dynasty for new validator
DEFAULT_END_DYNASTY: int128


@public
def __init__(
        epoch_length: int128, withdrawal_delay: int128, dynasty_logout_delay: int128,
        owner: address, sighasher: address, purity_checker: address,
        base_interest_factor: decimal, base_penalty_factor: decimal,
        min_deposit_size: wei_value):

    self.EPOCH_LENGTH = epoch_length
    self.WITHDRAWAL_DELAY = withdrawal_delay
    self.DYNASTY_LOGOUT_DELAY = dynasty_logout_delay
    self.OWNER = owner
    self.BASE_INTEREST_FACTOR = base_interest_factor
    self.BASE_PENALTY_FACTOR = base_penalty_factor
    self.MIN_DEPOSIT_SIZE = min_deposit_size

    # helper contracts
    self.SIGHASHER = sighasher
    self.PURITY_CHECKER = purity_checker

    # Start validator index counter at 1 because validator_indexes[] requires non-zero values
    self.next_validator_index = 1

    self.deposit_scale_factor[0] = 10000000000.0
    self.dynasty = 0
    self.current_epoch = floor(block.number / self.EPOCH_LENGTH)
    self.total_curdyn_deposits = 0
    self.total_prevdyn_deposits = 0
    self.DEFAULT_END_DYNASTY = 1000000000000000000000000000000


# ***** Constants *****
@public
@constant
def main_hash_voted_frac() -> decimal:
    return min(self.votes[self.current_epoch].cur_dyn_votes[self.expected_source_epoch] / self.total_curdyn_deposits,
               self.votes[self.current_epoch].prev_dyn_votes[self.expected_source_epoch] / self.total_prevdyn_deposits)


@public
@constant
def deposit_size(validator_index: int128) -> int128(wei):
    return floor(self.validators[validator_index].deposit * self.deposit_scale_factor[self.current_epoch])


@public
@constant
def total_curdyn_deposits_scaled() -> wei_value:
    return floor(self.total_curdyn_deposits * self.deposit_scale_factor[self.current_epoch])


@public
@constant
def total_prevdyn_deposits_scaled() -> wei_value:
    return floor(self.total_prevdyn_deposits * self.deposit_scale_factor[self.current_epoch])


# Helper functions that clients can call to know what to vote
@public
@constant
def recommended_source_epoch() -> int128:
    return self.expected_source_epoch


@public
@constant
def recommended_target_hash() -> bytes32:
    return blockhash(self.current_epoch*self.EPOCH_LENGTH - 1)


@private
@constant
def deposit_exists() -> bool:
    return self.total_curdyn_deposits > 0 and self.total_prevdyn_deposits > 0


# ***** Private *****

# Increment dynasty when checkpoint is finalized.
# TODO: Might want to split out the cases separately.
@private
def increment_dynasty():
    epoch: int128 = self.current_epoch
    # Increment the dynasty if finalized
    if self.votes[epoch - 2].is_finalized:
        self.dynasty += 1
        self.total_prevdyn_deposits = self.total_curdyn_deposits
        self.total_curdyn_deposits += self.dynasty_wei_delta[self.dynasty]
        self.dynasty_start_epoch[self.dynasty] = epoch
    self.dynasty_in_epoch[epoch] = self.dynasty
    if self.main_hash_justified:
        self.expected_source_epoch = epoch - 1
    self.main_hash_justified = False


# Returns number of epochs since finalization.
@private
def esf() -> int128:
    return self.current_epoch - self.last_finalized_epoch


# Returns the current collective reward factor, which rewards the dynasty for high-voting levels.
@private
def collective_reward() -> decimal:
    epoch: int128 = self.current_epoch
    live: bool = self.esf() <= 2
    if not self.deposit_exists() or not live:
        return 0.0
    # Fraction that voted
    cur_vote_frac: decimal = self.votes[epoch - 1].cur_dyn_votes[self.expected_source_epoch] / self.total_curdyn_deposits
    prev_vote_frac: decimal = self.votes[epoch - 1].prev_dyn_votes[self.expected_source_epoch] / self.total_prevdyn_deposits
    vote_frac: decimal = min(cur_vote_frac, prev_vote_frac)
    return vote_frac * self.reward_factor / 2


@private
def insta_finalize():
    epoch: int128 = self.current_epoch
    self.main_hash_justified = True
    self.votes[epoch - 1].is_justified = True
    self.votes[epoch - 1].is_finalized = True
    self.last_justified_epoch = epoch - 1
    self.last_finalized_epoch = epoch - 1
    # Log previous Epoch status update
    log.Epoch(epoch - 1, self.checkpoint_hashes[epoch - 1], True, True)


# Compute square root factor
@private
def sqrt_of_total_deposits() -> decimal:
    epoch: int128 = self.current_epoch
    ether_deposited_as_number: int128 = floor(max(self.total_prevdyn_deposits, self.total_curdyn_deposits) *
                                      self.deposit_scale_factor[epoch - 1] / as_wei_value(1, "ether")) + 1
    sqrt: decimal = ether_deposited_as_number / 2.0
    for i in range(20):
        sqrt = (sqrt + (ether_deposited_as_number / sqrt)) / 2
    return sqrt


# ***** Public *****

# Called at the start of any epoch
@public
def initialize_epoch(epoch: int128):
    # Check that the epoch actually has started
    computed_current_epoch: int128 = floor(block.number / self.EPOCH_LENGTH)
    assert epoch <= computed_current_epoch and epoch == self.current_epoch + 1

    # Setup
    self.current_epoch = epoch

    self.last_voter_rescale = 1 + self.collective_reward()
    self.last_nonvoter_rescale = self.last_voter_rescale / (1 + self.reward_factor)
    self.deposit_scale_factor[epoch] = self.deposit_scale_factor[epoch - 1] * self.last_nonvoter_rescale

    if self.deposit_exists():
        # Set the reward factor for the next epoch.
        adj_interest_base: decimal = self.BASE_INTEREST_FACTOR / self.sqrt_of_total_deposits()
        self.reward_factor = adj_interest_base + self.BASE_PENALTY_FACTOR * (self.esf() - 2)
        # ESF is only thing that is changing and reward_factor is being used above.
        assert self.reward_factor > 0
    else:
        # Before the first validator deposits, new epochs are finalized instantly.
        self.insta_finalize()
        self.reward_factor = 0

    # Increment the dynasty if finalized
    self.increment_dynasty()

    # Store checkpoint hash for easy access
    self.checkpoint_hashes[epoch] = self.recommended_target_hash()
    # Log new epoch creation
    log.Epoch(epoch, self.checkpoint_hashes[epoch], False, False)


@public
@payable
def deposit(validation_addr: address, withdrawal_addr: address):
    assert self.current_epoch == floor(block.number / self.EPOCH_LENGTH)
    assert extract32(raw_call(self.PURITY_CHECKER, concat('\xa1\x90>\xab', convert(validation_addr, 'bytes32')), gas=500000, outsize=32), 0) != convert(0, 'bytes32')
    assert not self.validator_indexes[withdrawal_addr]
    assert msg.value >= self.MIN_DEPOSIT_SIZE
    start_dynasty: int128 = self.dynasty + 2
    scaled_deposit: decimal(wei/m) = msg.value / self.deposit_scale_factor[self.current_epoch]
    self.validators[self.next_validator_index] = {
        deposit: scaled_deposit,
        start_dynasty: start_dynasty,
        end_dynasty: self.DEFAULT_END_DYNASTY,
        addr: validation_addr,
        withdrawal_addr: withdrawal_addr
    }
    self.validator_indexes[withdrawal_addr] = self.next_validator_index
    self.next_validator_index += 1
    self.dynasty_wei_delta[start_dynasty] += scaled_deposit
    # Log deposit event
    log.Deposit(withdrawal_addr, self.validator_indexes[withdrawal_addr], validation_addr, self.validators[self.validator_indexes[withdrawal_addr]].start_dynasty, msg.value)


@public
def logout(validator_index:int128, epoch: int128):
    assert self.current_epoch == floor(block.number / self.EPOCH_LENGTH)
    # Get hash for signature, and implicitly assert that it is an RLP list
    # consisting solely of RLP elements
#    sighash: bytes32 = extract32(raw_call(self.SIGHASHER, logout_msg, gas=200000, outsize=32), 0)
    # Extract parameters
#    values = RLPList(logout_msg, [int128, int128, bytes])
#    validator_index: int128 = values[0]
#    epoch: int128 = values[1]
#    sig: bytes <= 1024 = values[2]
    assert self.current_epoch >= epoch
    # Signature check
#    assert extract32(raw_call(self.validators[validator_index].addr, concat(sighash, sig), gas=500000, outsize=32), 0) == convert(1, 'bytes32')
    # Check that we haven't already withdrawn
    end_dynasty: int128 = self.dynasty + self.DYNASTY_LOGOUT_DELAY
    assert self.validators[validator_index].end_dynasty > end_dynasty
    # Set the end dynasty
    self.validators[validator_index].end_dynasty = end_dynasty
    self.dynasty_wei_delta[end_dynasty] -= self.validators[validator_index].deposit
    # Log logout event
    log.Logout(self.validators[validator_index].withdrawal_addr, validator_index, self.validators[validator_index].end_dynasty)


# Removes a validator from the validator pool
@private
def delete_validator(validator_index: int128):
    self.validator_indexes[self.validators[validator_index].withdrawal_addr] = 0
    self.validators[validator_index] = {
        deposit: 0,
        start_dynasty: 0,
        end_dynasty: 0,
        addr: None,
        withdrawal_addr: None
    }


# Withdraw deposited ether
@public
def withdraw(validator_index: int128):
    # Check that we can withdraw
    assert self.dynasty >= self.validators[validator_index].end_dynasty + 1
    end_epoch: int128 = self.dynasty_start_epoch[self.validators[validator_index].end_dynasty + 1]
    assert self.current_epoch >= end_epoch + self.WITHDRAWAL_DELAY
    # Withdraw
    withdraw_amount: int128(wei) = floor(self.validators[validator_index].deposit * self.deposit_scale_factor[end_epoch])
    send(self.validators[validator_index].withdrawal_addr, withdraw_amount)
    # Log withdraw event
    log.Withdraw(self.validators[validator_index].withdrawal_addr, validator_index, withdraw_amount)
    self.delete_validator(validator_index)


# Reward the given validator & miner, and reflect this in total deposit figured
@private
def proc_reward(validator_index: int128, reward: int128(wei/m)):
    # Reward validator
    self.validators[validator_index].deposit += reward
    start_dynasty: int128 = self.validators[validator_index].start_dynasty
    end_dynasty: int128 = self.validators[validator_index].end_dynasty
    current_dynasty: int128 = self.dynasty
    past_dynasty: int128 = current_dynasty - 1
    if ((start_dynasty <= current_dynasty) and (current_dynasty < end_dynasty)):
        self.total_curdyn_deposits += reward
    if ((start_dynasty <= past_dynasty) and (past_dynasty < end_dynasty)):
        self.total_prevdyn_deposits += reward
    if end_dynasty < self.DEFAULT_END_DYNASTY:  # validator has submit `logout`
        self.dynasty_wei_delta[end_dynasty] -= reward
    # Reward miner
    send(block.coinbase, floor(reward * self.deposit_scale_factor[self.current_epoch] / 8))


# Process a vote message
@public
#def vote(vote_msg: bytes[1024]):
def vote(validator_index: int128, target_hash: bytes32, target_epoch: int128, source_epoch: int128):
    # Get hash for signature, and implicitly assert that it is an RLP list
    # consisting solely of RLP elements
#    sighash: bytes32 = extract32(raw_call(self.SIGHASHER, vote_msg, gas=200000, outsize=32), 0)
    # Extract parameters
#    values = RLPList(vote_msg, [int128, bytes32, int128, int128, bytes])
#    validator_index: int128 = values[0]
#    target_hash: bytes32 = values[1]
#    target_epoch: int128 = values[2]
#    source_epoch: int128 = values[3]
#    sig: bytes[1024] = values[4]

    # Check the signature
#    assert extract32(raw_call(self.validators[validator_index].addr, concat(sighash, sig), gas=500000, outsize=32), 0) == convert(1, 'bytes32')
    # Check that this vote has not yet been made
    assert not bitwise_and(self.votes[target_epoch].vote_bitmap[floor(validator_index / 256)],
                           shift(convert(1, 'uint256'), validator_index % 256))
    # Check that the vote's target epoch and hash are correct
    assert target_hash == self.recommended_target_hash()
    assert target_epoch == self.current_epoch
    # Check that the vote source points to a justified epoch
    assert self.votes[source_epoch].is_justified

    # ensure validator can vote for the target_epoch
    start_dynasty: int128 = self.validators[validator_index].start_dynasty
    end_dynasty: int128 = self.validators[validator_index].end_dynasty
    current_dynasty: int128 = self.dynasty
    past_dynasty: int128 = current_dynasty - 1
    in_current_dynasty: bool = ((start_dynasty <= current_dynasty) and (current_dynasty < end_dynasty))
    in_prev_dynasty: bool = ((start_dynasty <= past_dynasty) and (past_dynasty < end_dynasty))
    assert in_current_dynasty or in_prev_dynasty

    # Record that the validator voted for this target epoch so they can't again
    self.votes[target_epoch].vote_bitmap[floor(validator_index / 256)] = \
        bitwise_or(self.votes[target_epoch].vote_bitmap[floor(validator_index / 256)],
                   shift(convert(1, 'uint256'), validator_index % 256))

    # Record that this vote took place
    current_dynasty_votes: decimal(wei/m) = self.votes[target_epoch].cur_dyn_votes[source_epoch]
    previous_dynasty_votes: decimal(wei/m) = self.votes[target_epoch].prev_dyn_votes[source_epoch]
    if in_current_dynasty:
        current_dynasty_votes += self.validators[validator_index].deposit
        self.votes[target_epoch].cur_dyn_votes[source_epoch] = current_dynasty_votes
    if in_prev_dynasty:
        previous_dynasty_votes += self.validators[validator_index].deposit
        self.votes[target_epoch].prev_dyn_votes[source_epoch] = previous_dynasty_votes

    # Process rewards.
    # Pay the reward if the vote was submitted in time and the vote is voting the correct data
    if self.expected_source_epoch == source_epoch:
        reward: int128(wei/m) = floor(self.validators[validator_index].deposit * self.reward_factor)
        self.proc_reward(validator_index, reward)

    # If enough votes with the same source_epoch and hash are made,
    # then the hash value is justified
    if (current_dynasty_votes >= self.total_curdyn_deposits * 2 / 3 and
            previous_dynasty_votes >= self.total_prevdyn_deposits * 2 / 3) and \
            not self.votes[target_epoch].is_justified:
        self.votes[target_epoch].is_justified = True
        self.last_justified_epoch = target_epoch
        self.main_hash_justified = True

        # Log target epoch status update
        log.Epoch(target_epoch, self.checkpoint_hashes[target_epoch], True, False)

        # If two epochs are justified consecutively,
        # then the source_epoch finalized
        if target_epoch == source_epoch + 1:
            self.votes[source_epoch].is_finalized = True
            self.last_finalized_epoch = source_epoch
            # Log source epoch status update
            log.Epoch(source_epoch, self.checkpoint_hashes[source_epoch], True, True)

    # Log vote event
    log.Vote(self.validators[validator_index].withdrawal_addr, validator_index, target_hash, target_epoch, source_epoch)


# Cannot make two prepares in the same epoch; no surrond vote.
@public
def slash(vote_msg_1: bytes[1024], vote_msg_2: bytes[1024]):
    # Message 1: Extract parameters
    sighash_1: bytes32 = extract32(raw_call(self.SIGHASHER, vote_msg_1, gas=200000, outsize=32), 0)
    values_1 = RLPList(vote_msg_1, [int128, bytes32, int128, int128, bytes])
    validator_index_1: int128 = values_1[0]
    target_epoch_1: int128 = values_1[2]
    source_epoch_1: int128 = values_1[3]
    sig_1: bytes[1024] = values_1[4]
    # Check the signature for vote message 1
    assert extract32(raw_call(self.validators[validator_index_1].addr, concat(sighash_1, sig_1), gas=500000, outsize=32), 0) == convert(1, 'bytes32')
    # Message 2: Extract parameters
    sighash_2: bytes32 = extract32(raw_call(self.SIGHASHER, vote_msg_2, gas=200000, outsize=32), 0)
    values_2 = RLPList(vote_msg_2, [int128, bytes32, int128, int128, bytes])
    validator_index_2: int128 = values_2[0]
    target_epoch_2: int128 = values_2[2]
    source_epoch_2: int128 = values_2[3]
    sig_2: bytes[1024] = values_2[4]
    # Check the signature for vote message 2
    assert extract32(raw_call(self.validators[validator_index_2].addr, concat(sighash_2, sig_2), gas=500000, outsize=32), 0) == convert(1, 'bytes32')
    # Check the messages are from the same validator
    assert validator_index_1 == validator_index_2
    # Check the messages are not the same
    assert sighash_1 != sighash_2
    # Detect slashing
    slashing_condition_detected: bool = False
    if target_epoch_1 == target_epoch_2:
        # NO DBL VOTE
        slashing_condition_detected = True
    elif (target_epoch_1 > target_epoch_2 and source_epoch_1 < source_epoch_2) or \
            (target_epoch_2 > target_epoch_1 and source_epoch_2 < source_epoch_1):
        # NO SURROUND VOTE
        slashing_condition_detected = True
    assert slashing_condition_detected
    # Delete the offending validator, and give a 4% "finder's fee"
    validator_deposit: int128(wei) = self.deposit_size(validator_index_1)
    slashing_bounty: int128(wei) = floor(validator_deposit / 25)
    deposit_destroyed: int128(wei) = validator_deposit - slashing_bounty
    self.total_destroyed += deposit_destroyed
    # Log slashing
    log.Slash(msg.sender, self.validators[validator_index_1].withdrawal_addr, validator_index_1, slashing_bounty, deposit_destroyed)

    # if validator not logged out yet, remove total from next dynasty
    end_dynasty: int128 = self.validators[validator_index_1].end_dynasty
    if self.dynasty < end_dynasty:
        deposit: decimal(wei/m) = self.validators[validator_index_1].deposit
        self.dynasty_wei_delta[self.dynasty + 1] -= deposit

        # if validator was already staged for logout at end_dynasty,
        # ensure that we don't doubly remove from total
        if end_dynasty < self.DEFAULT_END_DYNASTY:
            self.dynasty_wei_delta[end_dynasty] += deposit

    self.delete_validator(validator_index_1)
    send(msg.sender, slashing_bounty)


# Temporary backdoor for testing purposes (to allow recovering destroyed deposits)
@public
def owner_withdraw():
    send(self.OWNER, self.total_destroyed)
    self.total_destroyed = 0


# Change backdoor address (set to zero to remove entirely)
@public
def change_owner(new_owner: address):
    if self.OWNER == msg.sender:
        self.OWNER = new_owner
