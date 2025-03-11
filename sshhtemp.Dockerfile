FROM sshhbase:latest

EXPOSE 2222
ADD ./main.sh /main.sh
RUN chmod +x /main.sh

ENTRYPOINT ["/main.sh"]
