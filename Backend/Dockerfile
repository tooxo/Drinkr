FROM rcarmo/ubuntu-python:onbuild

RUN apt update && apt-get install software-properties-common --no-install-recommends -y && add-apt-repository ppa:chris-needham/ppa -y \
    && apt-get update -y \
    && apt-get install audiowaveform -y

WORKDIR /home/src/

ADD server.py /home/src/server.py

EXPOSE 3000

CMD ["python", "server.py"]