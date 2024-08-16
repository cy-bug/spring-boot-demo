pipeline {
  agent {label '10-node'}
  tools {
    maven 'mvn' // 确保这个名字与 Jenkins 配置的 Maven 名字一致
  }
  stages {
    stage('Checkout') { // git拉取代码
	  steps {
	    git branch: 'master', url: 'https://gitee.com/dy5/spring-boot-demo.git'
	  }
	}
	stage('Build') {  // 编译、打包项目
	  steps { // 如果Dockerfile文件有mvn构建步骤，此步可有可不有，若有后续可以直接将jar包复制进镜像直接运行
	    sh 'mvn clean package'  // 清理旧的构建文件，并重新打包项目
	  }
	}
	stage('docker build') {   // 根据Dockerfile构建镜像,将构建好的jar包放入容器
	  steps {
	    script {
          docker.build("ops-cy-245:9998/library/java-project:${env.BUILD_ID}")
        }
	  }
	}
	stage('Push to Harbor') {  // 上传镜像至harbor
      steps {
        script {  // 'harbor-credentials' 是存储在 Jenkins 中的凭证 ID
          docker.withRegistry('http://ops-cy-245:9998/', 'harbor-account') { // 指定 Docker 仓库的 URL 和认证凭证
            docker.image("ops-cy-245:9998/library/java-project:${env.BUILD_ID}").push()
		    // 将构建好的Docker镜像推送到指定的Harbor仓库。docker.image方法返回一个Docker镜像对象，push()方法将其推送到 Docker 仓库。
          }
        }
      }
    }
	stage('docker run') {
	  steps {
	    script {
          // 使用 Docker 容器运行构建好的镜像
          sh "docker run -d --name java-project-container -p 8070:8888 ops-cy-245:9998/library/java-project:${env.BUILD_ID}"
        }
	  }
	}
  }
}
