# Repo for testing the ctapipe ML module ([#1767](https://github.com/cta-observatory/ctapipe/pull/1767))


## Input data

Data Files are dl2 files using the Prod5b La Palma Alpha array processed using
ctapipe `0.17.0`.

5 files are used:

1. gamma diffuse train energy
2. gamma diffuse train classifier
3. proton train classifier
4. gamma evaluation
5. proton evaluation

Files can be shared with CTA members on request.

## Processing

The `Makefile` trains the energy regressor on the first file,
applies it to the second and third, which are then used to train the classifier.

Then, both models are applied to the evaluation files.


## Performance

A notebook plotting some performance metrics is in `performance.ipynb`
