{ buildPythonPackage
, embedding-reader
, faiss
, fetchFromGitHub
, fire
, fsspec
, lib
, numpy
, pyarrow
, pytestCheckHook
, pythonRelaxDepsHook
}:

buildPythonPackage rec {
  pname = "autofaiss";
  version = "2.15.3";

  src = fetchFromGitHub {
    owner = "criteo";
    repo = pname;
    rev = "refs/tags/${version}";
    hash = "sha256-RJOOUMI4w1YPEjDKi0YkqTXU01AbVoPn2+Id6kdC5pA=";
  };

  nativeBuildInputs = [ pythonRelaxDepsHook ];

  pythonRemoveDeps = [
    # The `dataclasses` packages is a python2-only backport, unnecessary in
    # python3.
    "dataclasses"
    # We call it faiss, not faiss-cpu.
    "faiss-cpu"
  ];

  pythonRelaxDeps = [
    # As of v2.15.3, autofaiss asks for pyarrow<8 but we have pyarrow v9.0.0 in
    # nixpkgs at the time of writing (2022-12-15).
    "pyarrow"
  ];

  propagatedBuildInputs = [ embedding-reader fsspec numpy faiss fire pyarrow ];

  checkInputs = [ pytestCheckHook ];

  disabledTests = [
    # Attempts to spin up a Spark cluster and talk to it which doesn't work in
    # the Nix build environment.
    "test_build_partitioned_indexes"
    "test_index_correctness_in_distributed_mode_with_multiple_indices"
    "test_index_correctness_in_distributed_mode"
    "test_quantize_with_pyspark"
  ];

  meta = with lib; {
    description = "Automatically create Faiss knn indices with the most optimal similarity search parameters";
    homepage = "https://github.com/criteo/autofaiss";
    license = licenses.asl20;
    maintainers = with maintainers; [ samuela ];
  };
}
