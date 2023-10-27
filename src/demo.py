from pathlib import Path
from enum import Enum
import datasets

import typer

from bertopic import BERTopic
from bertopic.representation import KeyBERTInspired
from plotly.graph_objs import Figure
from sentence_transformers import SentenceTransformer
from sklearn.feature_extraction.text import CountVectorizer
from typing_extensions import Annotated

from hdbscan import HDBSCAN
from umap import UMAP


def _vis_path(parent: Path, dataset_id_or_path: str, name: str, vis_type: str) -> Path:
    path = parent / dataset_id_or_path
    path.mkdir(parents=True, exist_ok=True)
    return str(path / f"{name}.{vis_type}")


def sentences_from_dataset(
    language: str, dataset_id_or_path: str | Path, language_to_column: dict[str, str]
) -> list[str]:
    data = datasets.load_dataset(str(dataset_id_or_path), split="train")
    sentences_col = language_to_column[language]
    return list(data[sentences_col])


def create_bertopic(
    sentence_model: SentenceTransformer = SentenceTransformer(
        "sentence-transformers/LaBSE"
    ),
    hdbscan_model: HDBSCAN = HDBSCAN(
        min_samples=10, gen_min_span_tree=True, prediction_data=True
    ),
    umap_model: UMAP = UMAP(n_components=5, n_neighbors=15, min_dist=0.0),
    vectorizer_model: CountVectorizer = CountVectorizer(
        ngram_range=(1, 2), stop_words="english", min_df=10
    ),
    representation_model: KeyBERTInspired = KeyBERTInspired(),
    language: str = "english",
    verbose: bool = False,
) -> BERTopic:
    return BERTopic(
        language="multilingual",
        embedding_model=sentence_model,
        umap_model=umap_model,
        hdbscan_model=hdbscan_model,
        representation_model=representation_model,
        vectorizer_model=vectorizer_model,
        verbose=verbose,
    )


def write_visualizations(
    topic_model: BERTopic, vis_dir: Path, dataset_id_or_path: str
) -> None:
    for fig_func in (
        topic_model.visualize_barchart,
        topic_model.visualize_heatmap,
        topic_model.visualize_topics,
    ):
        name = fig_func.__name__.split("_")[-1]
        fig: Figure = fig_func()
        fig.write_html(_vis_path(vis_dir, dataset_id_or_path, name, "html"))
        fig.write_image(
            _vis_path(vis_dir, dataset_id_or_path, name, "png"), format="png"
        )


def save_model(
    topic_model: BERTopic,
    models_dir: Path,
    dataset_id_or_path: str,
    serialization: str = "safetensors",
) -> None:
    model_name = dataset_id_or_path.replace("/", "_")
    path = models_dir / model_name
    path.parent.mkdir(parents=True, exist_ok=True)
    topic_model.save(str(path), serialization=serialization)


app = typer.Typer(rich_markup_mode="markdown")


class LanguageChoices(str, Enum):
    english: str = "english"
    welsh: str = "welsh"


@app.command()
def train_topic_model(
    topics_language: Annotated[
        LanguageChoices, typer.Option()
    ] = LanguageChoices.english.value,
    dataset_id_or_path: str = typer.Option(
        default="techiaith/cofnodycynulliad_en-cy",
        help="ID or path to Huggingface Dataset",
    ),
    source_column: str = typer.Option(
        default="source",
        help="The name of the dataset column containing source sentences.",
    ),
    target_column: str = typer.Option(
        default="target",
        help="The name of the dataset column containing target sentences.",
    ),
    source_language: str = typer.Option(
        default="english", help="The language of sentences in the source language."
    ),
    target_language: str = typer.Option(
        default="welsh", help="The language of sentences in the target column."
    ),
    visualisations_dir: Path = typer.Option(default="/visualizations"),
    models_dir: Path = typer.Option(default="/models"),
):
    dataset_map = {
        source_language.lower(): source_column,
        target_language.lower(): target_column,
    }
    sentences = sentences_from_dataset(
        topics_language.value, dataset_id_or_path, dataset_map
    )
    sentence_model = SentenceTransformer("sentence-transformers/LaBSE")
    embeddings = sentence_model.encode(sentences, show_progress_bar=True)
    topic_model = create_bertopic(sentence_model).fit(sentences, embeddings)
    write_visualizations(topic_model, visualisations_dir, dataset_id_or_path)
    save_model(topic_model, models_dir, dataset_id_or_path)


if __name__ == "__main__":
    app()
