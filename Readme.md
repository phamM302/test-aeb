Build with
docker build -t matlab_with_toolboxes:r2023b .

Run with
docker run --init --rm -it -p 8888:8888 matlab_with_toolboxes:r2023b -browser
