# modelu-pwnc-demo

[Read this documentation in English](/docs/README.en.md)

Mae'r ystorfa hon yn dangos ein gwaith archwiliadol gyda modelu pwnc.

Yma rydyn ni'n defnyddio'r llyfrgell python [BERTopic][1] i ddarganfod pwnc sy'n bresennol ynddo
ein setiau data, gan ddefnyddio technegau [modelu pwnc][2] gyda'r nod gan ddefnyddio
y data hwn i awtomeiddio'r broses o gategoreiddio brawddegau ar gyfer parth hyfforddi
modelau cyfieithu peirianyddol penodol.

Mae'r ystorfa hon yn rhoi arddangosiad o'r dechneg hon, gan
rhagosodedig, mae'r cod hwn yn defnyddio ein set ddata ar gyfer y
[cofnod y cynulliad][3].

## Gofynion

Er mwyn rhedeg y cod canlynol, bydd angen:

- Linux (Mae'r ystrofa hwn wedi'i profi ar Ubuntu 20.04 Linux, ac ar Windows 10 yn defnyddio WSL2).
- Docker

## Lwytho

The following command will be build the docker image:

```bash
make
```

## Defnydd

### Hyfforddi y fodel pwnc

Bydd y gorchymyn canlynol yn hyfforddi model pwnc gan ddefnyddio set ddata yn y [HuggingFace format].

```bash
./scripts/docker_run.sh python /app/src/demo.py
```

Gallwch ddefnyddio set ddata arall a gynhelir ar HuggingFace (neu mewn cyfeirlyfr lleol yn y [HuggingFace format]), trwy gyflenwi'r opsiwn `-data set-id-neu-bath`, ac addasu enwau'r ffynhonnell aiaith darged a cholofnau yn unol â hynny.

Defnyddiwch yr opsiwn `--help` i weld yr holl opsiynau sydd ar gael ar gyfer gwneud hyn:

 ```bash
./scripts/docker_run.sh python /app/src/demo.py --help
```

#### Allbwn

Ar ôl i'r broses hyfforddi a ddisgrifir uchod gwblhau, bydd dau ffolder
wedi'u creu, yn gynwys yr allbwn y broses hyfforddi. Bydd y ffolderi yma wedi'u enwi ar sail enw yr set ddata a defnyddir.

`models/<dataset_id_or_path>` : Ffeiliau sy'n cynrychioli'r model pwnc, sy'n cael eu hail-lwytho a'u defnyddio ar gyfer tasgau eraill (megis rhagweld pwnciau newydd o'r data).

`visualizations/<dataset_id_or_path>`: Ffeilau llun ac HTML yn darlunio graffiau o'r modelau pwnc wedi'u estynnu.

Gallwch bori trwy'r cyfeiriadur delweddu a gweld y ffeilau a gynhyrchir trwy rhedeg y sgript:

```bash
./scripts/browse_visualizations.sh
```

Mae'r sgript hon yn rhedeg gweinydd gwe, gan argraffu'r URL lle mae cynnwys y cyfeiriadur yn cael ei wasanaethu:

```text
Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...
```

Teipwich `ctrl-c` (hold down both the "control" and "c" keys) in order to stop the server.

Enghraifft o'r siart bar o bynciau a ddarganfuwyd yn set ddata [cofnod y cynulliad]:

![image topics](docs/images/barchart.png)

## Defnyddio model pwnc hyfforddedig

Mae'r pyt cod isod yn dangos sut y gellir defnyddio'r model hyfforddedig
predict new topics on unseen data.

Isod, dangosir archwilio defnydd o'r model a arbedwyd gan ddefnyddio
seiswn rhyngweithiol python, wrth rhedeg:

```bash
./scripts/docker_run.sh python
```

```python
>>> from pprint import pprint
>>> import bertopic
>>> model = bertopic.BERTopic.load("models/techiaith_cofnodycynulliad_en-cy")
>>> model.get_topic(0)
[['houses', 0.30775290727615356], ['homes', 0.2831276059150696], ['house', 0.27905571460723877], ['housing', 0.2523578405380249], ['house building', 0.2428145706653595], ['flats', 0.23407748341560364], ['residential', 0.2285560667514801], ['new homes', 0.22741946578025818], ['residents', 0.22725170850753784], ['affordable homes', 0.22647340595722198]]
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
