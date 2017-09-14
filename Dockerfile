FROM scratch

ENTRYPOINT ["/bin/tini", "--"]
CMD ["/bin/websocket-testing-api"]

EXPOSE 80

COPY build/bin/ /bin/
