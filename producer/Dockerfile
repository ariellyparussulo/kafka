FROM python:3.9-slim

ENV USER="producer"
ENV UUID=1001

WORKDIR /producer

RUN mkdir -p "/home/$USER" && \
    mkdir -p /home/$USER/.local/bin && \
    useradd  --home-dir "/home/$USER" --uid "$UUID" "$USER" && \
    echo "PATH=$PATH/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" > /home/$USER/.bashrc && \
    chown -R "$USER:$USER" "/home/$USER"

USER $USER
COPY --chown=$USER:$USER ./ ./
RUN pip install -r requirements.txt

EXPOSE 9000

ENTRYPOINT [ "python", "producer_server.py" ]