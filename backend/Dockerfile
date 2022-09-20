
FROM registry.1retail-dev.asia/system/dotnet-asp-runtime:6.0
##ADD /home/src-build /temp/

COPY out/ app/
WORKDIR /app

##### copy endtrypoint from branch dev.cicd #######
COPY run.sh .
###################################################

RUN ls -l
ENV TZ=Asia/Ho_Chi_Minh
# RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata && rm -rf /var/lib/apt/lists/*
# ENV TZ=Asia/Ho_Chi_Minh
# RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# RUN dpkg-reconfigure --frontend noninteractive tzdata
# RUN apt-get -y update \
#     && apt-get -y install telnet vim net-tools \
#     && rm -rf /var/lib/apt/lists/*
RUN apt-get -y update \
      && apt-get -y install libgdiplus

ENTRYPOINT ["/bin/bash", "run.sh"]
