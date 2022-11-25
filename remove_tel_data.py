import tables
from argparse import ArgumentParser
import warnings


parser = ArgumentParser()
parser.add_argument("inputfile")
parser.add_argument("outputfile")


table_paths = [
    "/simulation/service/shower_distribution",
    "/simulation/event/subarray/shower",
    "/dl2/event/subarray/classification/RandomForestClassifier",
    "/dl2/event/subarray/energy/RandomForestRegressor",
    "/dl2/event/subarray/geometry/HillasReconstructor",
    "/dl1/event/subarray/trigger",
]


if __name__ == "__main__":
    args = parser.parse_args()

    with (
        tables.open_file(args.inputfile, mode="r") as infile,
        tables.open_file(args.outputfile, mode="w") as outfile,
    ):
        with warnings.catch_warnings():
            warnings.simplefilter("ignore", category=tables.NaturalNameWarning)
            infile.copy_node_attrs(infile.root, outfile.root)

        infile.copy_node("/configuration", outfile.root, recursive=True)

        for table_path in table_paths:
            group_path, _, table_name = table_path.rpartition('/')
            group_parent, _, group_name = group_path.rpartition('/')

            group = outfile.create_group(group_parent, group_name, createparents=True)
            infile.copy_node(table_path, group)
