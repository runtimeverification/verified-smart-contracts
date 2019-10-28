pipeline {
  agent {
    dockerfile {
      label 'proofs'
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
/*    stage('Check revisions') {
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
    }
*/
    stage('Set vars') {
      steps {
        script {
          env.K_OPTS = "-Xmx12g -Xss48m"
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
      } }
    }
    stage('Minimal') {
      steps { ansiColor('xterm') {
          sh ' make jenkins MODE=MINIMAL NPROCS="$NPROCS" '
      } }
    }
    stage('KTest') {
      steps { ansiColor('xterm') {
          sh ' make jenkins MODE=KTEST NPROCS="$NPROCS" '
      } }
    }
    stage('ERC20') {
      steps { ansiColor('xterm') {
          sh ' make jenkins MODE=ERC20 NPROCS="$NPROCS" '
      } }
    }
    stage('Gnosis') {
      steps { ansiColor('xterm') {
          sh ' make jenkins MODE=GNOSIS NPROCS="$NPROCS" '
      } }
    }
    stage('Bihu') {
      steps { ansiColor('xterm') {
          sh ' make jenkins MODE=BIHU NPROCS="$NPROCS" '
      } }
    }
/*    stage('ERC20 mainnet') {
      steps { ansiColor('xterm') {
          sh ' make -C erc20/all/mainnet-specs test NPROCS="$NPROCS" '
      } }
    }*/
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
}
