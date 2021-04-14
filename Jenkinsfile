pipeline {
  agent {
    dockerfile {
      label 'proofs'
      additionalBuildArgs '--build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)'
    }
  }
  environment {
    VSC_USE_KSERVER           = false

    VSC_ERC20_SOLAR_ENABLED   = true
    VSC_MINIMAL_ENABLED       = true
    VSC_MAINNET_TEST_ENABLED  = true
    VSC_KTEST_ENABLED         = true
    VSC_ERC20_ENABLED         = true
    VSC_DEPOSIT_ENABLED       = true
    VSC_GNOSIS_ENABLED        = true
    VSC_BIHU_ENABLED          = true
    VSC_UNISWAP_ENABLED       = true
    VSC_ERC20_MAINNET_ENABLED = false
    VSC_ERC20_MAINNET_SOLAR_ENABLED = false
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
    /*stage('Check revisions') {
      steps {
        ansiColor('xterm') {
          sh '''
            krev=$(cat .build/.k.rev)
            for krev_file in $(find -name '.k.rev'); do
                current_krev=$(cat $krev_file)
                [ "$krev" = "$current_krev" ] || exit 1
            done
            kevmrev=$(cat .build/.kevm.rev)
            for kevmrev_file in $(find -name '.kevm.rev'); do
                current_kevmrev=$(cat $kevmrev_file)
                [ "$kevmrev" = "$current_kevmrev" ] || exit 1
            done
          '''
        }
      }
    }*/
    stage('Set vars') {
      steps {
        script {
          if (env.VSC_USE_KSERVER.toBoolean()) {
            env.K_OPTS = "-Xmx30g -Xss48m"
          } else {
            env.K_OPTS = "-Xmx12g -Xss48m"
          }
          env.NPROCS = sh(script: 'nproc', returnStdout: true)
          if (env.NPROCS.trim().toInteger() > 6) {
            env.NPROCS = "6"
          }
        }
        sh 'printenv'
      }
    }
    stage('Dependencies') {
      steps { ansiColor('xterm') {
          sh 'make -C resources deps'
          script { 
            if (env.VSC_USE_KSERVER.toBoolean()) {
              sh '''
                echo 'Starting kserver...'
                make -C resources spawn-kserver
              '''
            }
          }
      } }
    }
    //todo move after Minimal
    stage('Solar') {
      when {
        environment name: 'VSC_ERC20_SOLAR_ENABLED', value: 'true'
      }
      steps { ansiColor('xterm') {
          sh ' make jenkins MODE=SOLAR NPROCS="$NPROCS" '
      } }
    }
    stage('Minimal') {
      when {
        environment name: 'VSC_MINIMAL_ENABLED', value: 'true'
      }
      steps { ansiColor('xterm') {
          sh ' make jenkins MODE=MINIMAL NPROCS="$NPROCS" '
      } }
    }
    stage('Mainnet Test') {
      when {
        environment name: 'VSC_MAINNET_TEST_ENABLED', value: 'true'
      }
      steps { ansiColor('xterm') {
          sh ' make -C erc20/all/mainnet-test test NPROCS="$NPROCS" TIMEOUT=30m '
          sh ' make -C erc20/all/mainnet-solar-test test NPROCS="$NPROCS" TIMEOUT=30m '
      } }
    }
    stage('KTest') {
      when {
        environment name: 'VSC_KTEST_ENABLED', value: 'true'
      }
      steps { ansiColor('xterm') {
          sh ' make jenkins MODE=KTEST NPROCS="$NPROCS" '
      } }
    }
    stage('ERC20') {
      when {
        environment name: 'VSC_ERC20_ENABLED', value: 'true'
      }
      steps { ansiColor('xterm') {
          sh ' make jenkins MODE=ERC20 NPROCS="$NPROCS" '
      } }
    }
    stage('Deposit') {
      when {
        environment name: 'VSC_DEPOSIT_ENABLED', value: 'true'
      }
      steps { ansiColor('xterm') {
          sh ' make jenkins MODE=DEPOSIT NPROCS="$NPROCS" '
      } }
    }
    stage('Gnosis') {
      when {
        environment name: 'VSC_GNOSIS_ENABLED', value: 'true'
      }
      steps { ansiColor('xterm') {
          sh ' make jenkins MODE=GNOSIS NPROCS="$NPROCS" '
      } }
    }
    stage('Bihu') {
      when {
        environment name: 'VSC_BIHU_ENABLED', value: 'true'
      }
      steps { ansiColor('xterm') {
          sh ' make jenkins MODE=BIHU NPROCS="$NPROCS" '
      } }
    }
    stage('Uniswap') {
      when {
        environment name: 'VSC_UNISWAP_ENABLED', value: 'true'
      }
      steps { ansiColor('xterm') {
          sh ' make jenkins MODE=UNISWAP NPROCS="$NPROCS" '
      } }
    }
    stage('ERC20 Mainnet') {
      when {
        environment name: 'VSC_ERC20_MAINNET_ENABLED', value: 'true'
      }
      steps { ansiColor('xterm') {
        sh '''
          export EXT_KPROVE_OPTS="--branching-allowed 16"
          make -C erc20/all/mainnet-specs test NPROCS="$NPROCS" TIMEOUT=30m
        '''
      } }
    }
    stage('ERC20 Mainnet Solar') {
      when {
        environment name: 'VSC_ERC20_MAINNET_SOLAR_ENABLED', value: 'true'
      }
      steps { ansiColor('xterm') {
        sh '''
          export EXT_KPROVE_OPTS="--branching-allowed 16"
          make -C erc20/all/mainnet-solar-specs test NPROCS="$NPROCS" TIMEOUT=30m
        '''
      } }
    }
    stage('Check K revision') {
      steps {
        ansiColor('xterm') {
          dir('.build/k') {
            git credentialsId: 'rv-jenkins', url: 'git@github.com:kframework/k.git'
          }
          sh '''
            cd .build/k
            git branch --contains $(cat ../.k.rev) | grep -q master
          '''
        }
      }
    }
    stage('Update Git Tags') {
      when {
        not { changeRequest() }
        branch 'master'
      }
      steps {
        ansiColor('xterm') {
          dir('.build/evm-semantics') {
            git credentialsId: 'rv-jenkins', url: 'git@github.com:kframework/evm-semantics.git'
          }
          sh '''
            krev=$(cat .build/.k.rev)
            cd .build/k
            git fetch
            git tag --force vsc $krev
            git push --delete origin vsc || true
            git push origin vsc:vsc

            cd ../..

            kevmrev=$(cat .build/.kevm.rev)
            cd .build/evm-semantics
            git fetch
            git tag --force vsc $kevmrev
            git push --delete origin vsc || true
            git push origin vsc:vsc
          '''
        }
      }
    }
  }
  post {
    always {
      sh 'make -C resources stop-kserver'
      //archiveArtifacts 'kserver.log,k-distribution/target/kserver.log'
    }
  }
}
