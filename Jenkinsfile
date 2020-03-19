pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps {
        echo 'Checkout...'
        checkout scm
        stash 'sources'
      }
    }
    stage('Build') {
      steps {
        echo 'Build...'
        unstash 'sources'
        sh 'mvn clean package -DskipTests'
        stash 'sources'
      }
    }
  }
}
