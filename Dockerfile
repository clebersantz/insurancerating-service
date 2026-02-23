FROM rocker/r-ver:4.4.2

RUN install2.r --error \
    plumber \
    insurancerating \
    dplyr

WORKDIR /app

COPY plumber.R .

EXPOSE 8080

CMD ["Rscript", "-e", "plumber::plumb('plumber.R')$run(host='0.0.0.0', port=8080)"]
