#!groovy
@Library('c2c-pipeline-library') import static com.camptocamp.utils.*

IMAGE_NAME = 'camptocamp/qgis-server'

if (env.BRANCH_NAME == 'master') {
  finalTag = 'latest'
} else {
  finalTag = env.BRANCH_NAME
}

selectNodes {
    it.kernel == 'Linux' &&
    (it.memorysize_mb as Float) > 6000
}

dockerBuild {
    // make sure we don't mess with another build by using latest on both
    env.DOCKER_TAG = env.BUILD_TAG

    stage('Update docker') {
        checkout scm
        sh 'make pull'
    }

    //rebuild every nights
    setCronTrigger('H H(0-8) * * *')

    stage('Build') {
        checkout scm
        sh 'make -j3 clean build'
    }
    stage('Test') {
        checkout scm
        try {
            lock("acceptance-${env.NODE_NAME}") {
                sh 'make -j3 acceptance-quick'  //quick because we don't want to rebuild the image
            }
        } finally {
            junit keepLongStdio: true, testResults: 'acceptance_tests/junitxml/*.xml'
        }
    }

    //compute the list of tags we are going to push
    if (finalTag ==~ /\d+(?:\.\d+)*/) {
        parts = finalTag.tokenize('.')
        tags = []
        for (int i=1; i<=parts.size(); ++i) {
            curTag = "";
            for (int j = 0; j < i; ++j) {
                if (j > 0) curTag += '.'
                curTag += parts[j]
            }
            tags << curTag
        }
    } else {
        tags = [finalTag]
    }

    stage("Publish ${tags}") {
        withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub',
                        usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
            //login in docker hub
            sh 'docker login -u "$USERNAME" -p "$PASSWORD"'
            try {
                for (String tag: tags) {
                    //give the final tag to the image
                    sh "docker tag ${IMAGE_NAME}:${env.DOCKER_TAG} ${IMAGE_NAME}:${tag}"
                    //push it
                    docker.image("${IMAGE_NAME}:${tag}").push()
                }
            } finally {
                //logout from docker hub
                sh 'rm -rf ~/.docker*'
            }
        }
    }
}
