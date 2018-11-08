pipelineJob('springboot-gs-rest-service-build') {

  def repo = 'https://github.com/mattandes/springboot-gs-rest-service.git'

  triggers {
    scm('H/1 * * * *')
  }
  description("SpringBoot GS Rest Service Build")
  displayName("SpringBoot GS Rest Service Build")

  definition {
    cpsScm {
      scm {
        git {
          remote { url(repo) }
          branches('master')
          scriptPath('jenkins-pipeline/Jenkinsfile')
          extensions { }  // required as otherwise it may try to tag the repo, which you may not want
        }
      }
    }
  }
}