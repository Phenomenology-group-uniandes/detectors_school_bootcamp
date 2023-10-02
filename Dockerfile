FROM cfrc2694/uniandes-pheno-code-server:latest

# Clone the repo Phenomenology-group-uniandes/detectors_school_bootcamp
RUN cd /root/ && \ 
    git clone  https://github.com/Phenomenology-group-uniandes/detectors_school_bootcamp.git && \
    cd detectors_school_bootcamp && \
    git submodule  update --init --recursive

# Update pip
RUN  source /root/.bashrc && \
    pip install --upgrade pip && \
    pip install -r /root/detectors_school_bootcamp/requirements.txt

# Password for code-server
ENV PASSWORD="Feynman2023"

# # Start code-server on port 8080 and use the repo as the working directory
#CMD ["code-server", "--auth", "password", "--host", "0.0.0.0" , "--port", "8080", "/root/detectors_school_bootcamp/"   ]

# start a Jupyter lab server
CMD ["/bin/bash", "-c", "source /etc/bashrc && cd /root/detectors_school_bootcamp/ && jupyter-lab --ip=0.0.0.0 --port=8080 --allow-root --no-browser --NotebookApp.token=${PASSWORD} --NotebookApp.password='${PASSWORD}' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX} --NotebookApp.allow_remote_access=True --NotebookApp.notebook_dir=/root/detectors_school_bootcamp/"]
