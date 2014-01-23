import os

home = os.getenv('HOME')

build_path = os.path.join(home, "build")
install_path = "/usr/local"
source_path = os.path.join(home, "sources")
repository_path = os.path.join(home, "eb_repo")
repository = FileRepository(repository_path)
log_format = ("buildlogs", "%(name)s-%(version)s.log")
log_dir = os.path.join(home, "buildlogs")
