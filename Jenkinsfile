pipeline {
  agent {
    dockerfile {
      additionalBuildArgs '--build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)'
    }
  }
  stages {
    stage("Init title") {
      when { changeRequest() }
      steps {
        script {
          currentBuild.displayName = "PR ${env.CHANGE_ID}: ${env.CHANGE_TITLE}"
        }
      }
    }
    stage('Build K and KEVM') {
      steps {
        ansiColor('xterm') {
          sh '''
            cd .build
            git clone https://github.com/kframework/k
            cd k
            git reset --hard f9ec1ac0b4457021cb89439777078659bf4f852b
            mvn package -DskipTests -Dllvm.backend.skip
            cd ../
            git clone https://github.com/kframework/evm-semantics
            cd evm-semantics
            git clean -fdx
            git reset --hard f0a8d473676232c404ef3439260984505922a8e5
            make tangle-deps
            make defn
            ../.build/k/k-distribution/target/release/k/bin/kompile -v --debug --backend java -I .build/java -d .build/java \
                                 --main-module ETHEREUM-SIMULATION --syntax-module ETHEREUM-SIMULATION .build/java/driver.k

            cd ../../
            for subdir in k-test gnosis erc20; do
                ln --symbolic --force --no-dereference $(pwd)/.build/k             $subdir/.build/k
                ln --symbolic --force --no-dereference $(pwd)/.build/evm-semantics $subdir/.build/evm-semantics
            done
          '''
        }
      }
    }
    stage('Run Proofs') {
      steps {
        ansiColor('xterm') {
          sh '''
            nprocs=$(nproc)
            [ "$nprocs" -gt '6' ] && nprocs='6'
            export K_OPTS=-Xmx12g
            make jenkins MODE=all NPROCS="$nprocs"
          '''
        }
      }
    }
  }
}
