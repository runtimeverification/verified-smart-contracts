pipeline {
  agent {
    dockerfile {
      label 'proofs'
      additionalBuildArgs '--build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)'
    }
  }
  options {
    ansiColor('xterm')
  }
  stages {
    stage('Init title') {
      when { changeRequest() }
      steps {
        script {
          currentBuild.displayName = "PR ${env.CHANGE_ID}: ${env.CHANGE_TITLE}"
        }
      }
    }
    stage('Dependencies') {
      when { changeRequest() }
      steps {
        sh '''
          make --directory resources deps
        '''
      }
    }
    stage('Test Proofs') {
      when { changeRequest() }
      steps {
        sh '''
          nprocs=$(nproc)
          [ "$nprocs" -gt '6' ] && nprocs='6'
          export K_OPTS="-Xmx12g -Xss48m"
          make jenkins MODE=jenkins NPROCS="$nprocs"
        '''
      }
    }
    stage('Check KEVM revision') {
      when { changeRequest() }
      steps {
        sh '''
          cd .build/evm-semantics
          git fetch --all
          [ $(git merge-base origin/master HEAD) == $(git rev-parse HEAD) ]
        '''
      }
    }
  }
}
