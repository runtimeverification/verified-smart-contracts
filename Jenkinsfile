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
    stage("Install Z3") {
      steps {
        ansiColor('xterm') {
          sh '''
            mkdir scratch
            cd scratch
            git clone 'https://github.com/z3prover/z3'
            cd z3
            python scripts/mk_make.py --prefix=$HOME/.local
            cd build
            make -j4
            make install
            export PATH=$HOME/.local/bin:$PATH
            z3 --version
          '''
        }
      }
    }
    stage('Build and Test') {
      steps {
        ansiColor('xterm') {
          sh '''
            nprocs=$(nproc)
            [ "$nprocs" -gt '6' ] && nprocs='6'
            mode=all
            export K_OPTS=-Xmx12g
            make jenkins MODE="$mode" NPROCS="$nprocs"
          '''
        }
      }
    }
  }
}
