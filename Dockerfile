# 使用 Maven 和 OpenJDK 镜像作为构建环境
FROM maven:3.8.5-openjdk-17 AS build

# 设置工作目录
WORKDIR /app

# 将 pom.xml 和 src 目录复制到工作目录
COPY .mvn/ .mvn/
COPY src ./src
COPY pom.xml .
COPY mvnw .


# 确保 Maven Wrapper 文件具有执行权限
RUN chmod +x ./mvnw

# 配置 Maven 使用国内镜像和仓库源
RUN mkdir -p /root/.m2 && \
    echo '<settings>' \
    '<mirrors>' \
    '<mirror>' \
        '<id>nexus-aliyun</id>' \
        '<mirrorOf>central</mirrorOf>' \
        '<name>Nexus aliyun</name \
        '<url>http://maven.aliyun.com/nexus/content/groups/public</ur1>' \
    '</mirror>' \
    '<mirror>' \
    '<id>nexus-huawei</id>' \
    '<mirrorOf>central</mirrorOf>' \
    '<name>Nexus huawei</name>' \
    '<url>https://repo.huaweicloud.com/repository/maven/</url>' \
    '</mirror>' \
    '</mirrors>' \
    '</settings>' > /root/.m2/settings.xml

# 执行 Maven 构建
ENV MAVEN_CONFIG=""
RUN ./mvnw clean package -X

# 使用一个更小的基础镜像作为运行环境
FROM openjdk:17-slim

# 设置工作目录
WORKDIR /app

# 从构建阶段复制 JAR 文件到当前目录
COPY --from=build /app/target/*.jar app.jar

# 暴露应用运行所需的端口
EXPOSE 8080

# 设置默认的启动命令
ENTRYPOINT ["java", "-jar", "app.jar"]
