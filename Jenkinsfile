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
    stage("Init title") {
      when { changeRequest() }
      steps {
        script {
          currentBuild.displayName = "PR ${env.CHANGE_ID}: ${env.CHANGE_TITLE}"
        }
      }
    }
/*    stage('Check revisions') {
      when { changeRequest() }
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
    stage('Run Proofs') {
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
    stage('Check K revision') {
      steps {
        dir('.build/k') {
          git credentialsId: 'rv-jenkins', url: 'git@github.com:kframework/k.git'
        }
        sh '''
          cd .build/k
          git branch --contains $(cat ../.k.rev) | grep -q master
        '''
      }
    }
    stage('Update Git Tags') {
      when {
        not { changeRequest() }
        branch 'master'
      }
      steps {
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
