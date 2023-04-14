def execMatlab(String command) {
    def shellCommand = $/matlab -nodisplay -nosplash -nodesktop -r "${command}"/$
    sh shellCommand
}


def runMatlabTests() {
    if (env.BRANCH_NAME == "master" | env.BRANCH_NAME == "develop") {
        def matlabCommand = $/module.runtests(pwd, 'whichTests', 'extended', 'useParallel', true);/$
        execMatlab matlabCommand
    } else {
        def matlabCommand = $/module.runtests(pwd, 'whichTests', 'base', 'useParallel', true);/$
        execMatlab matlabCommand
    }
}


//def buildMexFiles() {
//    def matlabCommand = $/BMMO_XY.tools.xml.buildMexBinaries();/$
//    execMatlab matlabCommand
//}


def installMatlab(String matlabVersion) {
    sh 'mkdir -p ${CADENV_HOME}'
//    sh 'cadenv -t gcc'
    def shellCommand = $/cadenv -r "${matlabVersion}" matlab/$
    sh shellCommand
}


def createDecrypterConfiguration() {
    sh """echo "{\\"decrypterExecutable\\":\\"NOT PROVIDED\\",\\"token\\":\\"ef1f74ab-4499-4b62-8a09-8f1ae17a3022\\",\\"comment\\":\\"Baseliner_Overlay_EUV\\"}" | tee -a decrypterConfiguration.json"""
}


def notifyBitbucketBuildStatus(String state) {    
    if (state == "FINISHED") {
        currentBuild.result = currentBuild.result ?: 'SUCCESS'
    }
    def tmp_branchname = env.BRANCH_NAME
    env.BRANCH_NAME = env.BRANCH_NAME.replace('/', '%252F')  
    notifyBitbucket(
        credentialsId: '30ebcf38-64d8-4dc9-881f-00230b372f99',
        stashServerBaseUrl: 'https://litho-bitbucket.asml.com'
    )
    env.BRANCH_NAME = tmp_branchname
}


def GetWorkspace()
{
    node('fc065')
    {
        String orig_path = pwd()
        def new_path = orig_path.replace('@', '_')
        return "${new_path}_b${BUILD_NUMBER}"
    }
}


pipeline {
    agent {
        node {
            label 'fc065'
            customWorkspace GetWorkspace()
        }
    }
    environment {
        CADENV_HOME = "${WORKSPACE}/${BUILD_NUMBER}/caddir"
        PYTHONPATH = "${WORKSPACE}/${BUILD_NUMBER}/caddir/cadlib:lib/python:bin/python"
        LD_LIBRARY_PATH = "${WORKSPACE}/${BUILD_NUMBER}/caddir/cadlib:/lib:/usr/lib:/usr/local/lib"
        PATH = "${WORKSPACE}/${BUILD_NUMBER}/caddir/cadbin:/cadappl/bin:/bin:/usr/bin:/usr/sbin:/usr/local/bin:/sdev/user/bin"
    }
    stages {
        stage('Prepare') {
            steps {
                notifyBitbucketBuildStatus('INPROGRESS')
                installMatlab('2018b')
                createDecrypterConfiguration()
            }
        }
//        stage('Build MEX binaries') {
//            steps {
//                buildMexFiles()
//                archiveArtifacts artifacts: '+BMMO_XY/+tools/+xml/private/*.mexa64'
//            }
//        }
        stage('Execute Tests') {
            steps {
                runMatlabTests()
            }
        }
    }
    post {
        always {
            script {
                notifyBitbucketBuildStatus('FINISHED')
                cleanWs()
            }
        }
    }
}
