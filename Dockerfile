FROM osixia/openldap:1.1.7

COPY bootstrap.sh /container/tool/bootstrap
COPY bootstrap /container/service/slapd/assets/config/bootstrap

ENTRYPOINT ["/container/tool/bootstrap"]
