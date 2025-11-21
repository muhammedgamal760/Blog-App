pipeline {
    agent any
    triggers {
        githubPush()  // Triggered by GitHub webhook
    }
    stages {
        stage('Build') {
            steps {
                git 'https://github.com/muhammedgamal760/Blog-App'
                echo 'Building from webhook trigger...'
            }
        }
    }
}
