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
    stage('Run Proofs') {
      steps {
        ansiColor('xterm') {
          sh '''
            nprocs=$(nproc)
            [ "$nprocs" -gt '1' ] && nprocs='1'
            export K_OPTS=-Xmx12g
            make jenkins MODE=all NPROCS="$nprocs"
          '''
        }
      }
    }
  }
}
