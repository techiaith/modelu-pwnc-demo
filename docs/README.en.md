# modelu-pwnc-demo

[Darllen y dogfenaeth hwn yn yr Gymraeg](/docs/README.md.cy)

This repository shows our exploratory work with topic modelling.

Here we use the [BERTopic][1] python library to discover topic present in
our data sets, using [topic modelling][2] techniques with the aim using
this data to automate sentence categorisation for training domain
specific machine translation models.

This repository provides an demonstration of this technique, by
default, this code uses our data set for the [welsh assembly proceedings][3].

## Requirements

In order to run the following code, you'll need:

- A Linux based distribution (This has been tested on Ubuntu 20.04 on Linux and Windows using ESL2).
- Docker

## Installation

The following command will be build the docker image:

```bash
make
```

## Usage

### Training the topic model

The following command will train a topic model using a data set in the
[Hugging Face format].

```bash
./scripts/docker_run.sh python /app/src/demo.py
```

You can use another data set hosted on hugging face (or in a local directory in the [Hugging Face format]), by supplying the option `--data set-id-or-path`, and adjusting the names of the source and target language and columns accordingly.

 Use the help option to see the options available for doing this:

 ```bash
./scripts/docker_run.sh python /app/src/demo.py --help
```

#### Output

Once the training process described above has completed, two folders
will have been created, containing the output of the training
process. These folders are named according to the dataset the model
was trained on:

`models/<dataset_id_or_path>` : Files representing the topic model, that be re-loaded and used for other tasks (such as predicting topic from new data).

`visualizations/<dataset_id_or_path>`: HTML and image files depicting graphs of the topic models deduced.

You can browse the visualizations directory and view the generated
HTML and image files by running the following script:

```bash
./scripts/browse_visualizations.sh
```

This script runs a web server, printing out the URL at which the
directory contents are served:

```text
Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...
```

Type `ctrl-c` (hold down both the "control" and "c" keys) in order to stop the server.

Example of the bar-chart of topics discovered in the [welsh assembly proceedings] dataset:

![image topics](docs/images/barchart.png)

## Using a trained topic model

The code snippet below show how the trained model can be used to
predict new topics on unseen data.

Below, exploration of usage of the saved model is shown using an
interactive python session obtained by running:

```bash
./scripts/docker_run.sh python
```

```python
>>> import bertopic
>>> model = bertopic.BERTopic.load("models/techiaith_cofnodycynulliad_en-cy")
>>> model.get_topic(0)
[['houses', 0.30775290727615356], ['homes', 0.2831276059150696], ['house', 0.27905571460723877], ['housing', 0.2523578405380249], ['house building', 0.2428145706653595], ['flats', 0.23407748341560364], ['residential', 0.2285560667514801], ['new homes', 0.22741946578025818], ['residents', 0.22725170850753784], ['affordable homes', 0.22647340595722198]]
>>> from pprint import pprint
>>> pprint(model.get_topic(0))
[['houses', 0.30775290727615356],
 ['homes', 0.2831276059150696],
 ['house', 0.27905571460723877],
 ['housing', 0.2523578405380249],
 ['house building', 0.2428145706653595],
 ['flats', 0.23407748341560364],
 ['residential', 0.2285560667514801],
 ['new homes', 0.22741946578025818],
 ['residents', 0.22725170850753784],
 ['affordable homes', 0.22647340595722198]]
```

[1]: https://maartengr.github.io/BERTopic/
[2]: https://huggingface.co/blog/bertopic#what-is-topic-modelling
[3]: https://huggingface.co/datasets/techiaith/cofnodycynulliad_en-cy
