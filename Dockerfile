ARG PYTHONFULL
ARG ALPINE_VER
FROM $PYTHONFULL as builder

RUN apk add --no-cache binutils
RUN find /usr/local -name '*.so' | xargs strip -s
RUN pip uninstall -y pip
RUN set -ex && \
    cd /usr/local/lib/python*/config-*-x86_64-linux-gnu/ && \
    rm -rf *.o *.a
RUN rm -rf /usr/local/lib/python*/ensurepip
RUN rm -rf /usr/local/lib/python*/idlelib
RUN rm -rf /usr/local/lib/python*/distutils
RUN rm -rf /usr/local/lib/python*/lib2to2
RUN rm -rf /usr/local/lib/python*/__pycache__/*
RUN find /usr/local/include/python* -not -name pyconfig.h -type f -exec rm {} \;
RUN find /usr/local/bin -not -name 'python*' \( -type f -o -type l \) -exec rm {} \;
RUN rm -rf /usr/local/share/*

# The final image
FROM alpine:$ALPINE_VER as final

ENV LANG C.UTF-8
RUN apk add --no-cache libbz2 expat libffi xz-libs sqlite-libs readline ca-certificates
COPY --from=builder /usr/local/ /usr/local/

CMD ["python3"]
