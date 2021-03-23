all:
	docker build -t autoreduction/qp -f qp_mantid_python36.D ..
	sudo singularity build -F qp_mantid_python36.sif docker-daemon://autoreduction/qp:latest

from-remote:
	sudo singularity build -F qp_mantid_python36.sif docker://autoreduction/qp:latest

system:
	sudo yum install -y squashfs-tools
	wget https://golang.org/dl/go1.16.2.linux-amd64.tar.gz
	sudo tar -C /usr/local -xzf go1.16.2.linux-amd64.tar.gz
	sudo ln -s /usr/local/go/bin/go /usr/bin/go
	sudo ln -s /usr/local/go/bin/gofmt /usr/bin/gofmt
	sudo yum groupinstall -y 'Development Tools'

singularity:
	export VERSION=3.7.0 && wget https://github.com/hpcng/singularity/releases/download/v$${VERSION}/singularity-$${VERSION}.tar.gz && tar -xzf singularity-$${VERSION}.tar.gz
	cd singularity && ./mconfig && make -C builddir && sudo make -C builddir install
	sudo ln -s /usr/local/bin/singularity /usr/bin/singularity

deps: system singularity

run:
	# The bind expects the AR repo to be at ../, relative to this folder
	singularity run --bind ../:/autoreduce/ --bind /instrument:/instrument --bind /isis:/isis qp_mantid_python36.sif

instance:
	singularity instance start --bind ../:/autoreduce/ --bind /instrument:/instrument --bind /isis:/isis qp_mantid_python36.sif queue_processor