FROM alpine:latest
LABEL maintainer "goukun <goukun07@gmail.com>"

WORKDIR /root
COPY . /root

RUN set -ex \
	&& sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
	&& apk update && apk add --no-cache tzdata openssl ca-certificates \
	&& mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
	&& chmod +x /root/v2ray_dl.sh \
	&& chmod +x /root/v2ray_installer.sh \
	&& chmod +x /root/entrypoint.sh \
	&& sh -c /root/v2ray_installer.sh

VOLUME /etc/v2ray
CMD [ "/root/entrypoint.sh" ]
