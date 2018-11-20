#!groovy

// keep 20 builds history
properties([[$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', numToKeepStr: '20']]]);
def lib = library('ci-shared-libs').com.starup
def msgUtils = lib.MessageLego.new()
def buildAgent = 'docker-build-bj3a'
def dockerHub = 'registry.astarup.com/devops'
def projectName = 'ruby-nodejs'
buildHttpProxy = "http://proxy_hk.astarup.com:39628"
currentBuild.result = "SUCCESS"
imageName = "${dockerHub}/${projectName}"

builderTagRegex = /^builder-(\d+\.){0,1}\d+$/
runnerTagRegex = /^runner-(\d+\.){0,1}\d+$/

def commitMsg = ''
def branch = env.BRANCH_NAME
def bearychatHookUrl = env.BEARYCHAT_HOOK_URL
def bearychatHookGroup = 'devops'

def Object image
def gemToken = env.ZHULUX_GEM_PULL_KEY

/*
 Jenkinsfile main body
*/

try {
  node("${buildAgent}") {
    stage("Checkout Project") {
      def scmVars = checkout scm
      taskStartMsg = msgUtils.taskStart("Start building image ${imageName}...")
      bearyNotifySend attachments: "${taskStartMsg}", channel: "${bearychatHookGroup}", endpoint: "${bearychatHookUrl}"
    }

    stage("Build Image") {
      branchToFile = BranchToFile()
      image = docker.build("${imageName}","-f ${branchToFile} --build-arg http_proxy=${buildHttpProxy} --build-arg GEM_TOKEN=${gemToken}")
    }

    stage("Publish Image to Registry") {
      dockerPush(image,"${branch}")

      taskStartMsg = msgUtils.taskStart("镜像成功构建，并已上传到仓库.请更新所有依赖该镜像的项目中的Dockerfile. ${imageName}:${branch} ！")
      bearyNotifySend attachments: "${taskStartMsg}", channel: "${bearychatHookGroup}", endpoint: "${bearychatHookUrl}"
    }
  }

} catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException e) {
  node("${buildAgent}") {
    echo e.getCauses().join(", ")
    currentBuild.result = "ABORTED"
    errorMsg = msgUtils.errorMsg("${aborteMsg}")
    bearyNotifySend attachments: "${errorMsg}", channel: "${bearychatHookGroup}", endpoint: "${bearychatHookUrl}"
  }
} catch (err) {
  node("${buildAgent}") {
    currentBuild.result = "FAILURE"
    errorMsg = msgUtils.errorMsg(err,'')
    bearyNotifySend attachments: "${errorMsg}", channel: "${bearychatHookGroup}", endpoint: "${bearychatHookUrl}"
    throw err
  }
}

def BranchToFile() {
  if (env.BRANCH_NAME ==~ builderTagRegex) {
    return "Dockerfile.build"
  } else if (env.BRANCH_NAME ==~ runnerTagRegex) {
    return "Dockerfile.run"
  }
}
