OUTDIR=build


all: \
	${OUTDIR}/gamma-diffuse_eval.dl2.h5 \
	${OUTDIR}/gamma-diffuse_eval.reduced_dl2.h5 \
	${OUTDIR}/proton_eval.dl2.h5 \
	${OUTDIR}/proton_eval.reduced_dl2.h5 \
	${OUTDIR}/electron_eval.dl2.h5 \
	${OUTDIR}/electron_eval.reduced_dl2.h5 \
	${OUTDIR}/gamma_eval.dl2.h5 \
	${OUTDIR}/gamma_eval.reduced_dl2.h5 \


${OUTDIR}/%.reduced_dl2.h5: build/%.dl2.h5 remove_tel_data.py
	python remove_tel_data.py $< $@


${OUTDIR}/%_eval.dl2.h5: data/%_eval.dl2.h5 ${OUTDIR}/energy.pkl ${OUTDIR}/classifier.pkl apply_config.yml
	ctapipe-apply-models \
		-i $< -o $@ \
		--energy-regressor ${OUTDIR}/energy.pkl \
		--particle-classifier ${OUTDIR}/classifier.pkl \
		-c apply_config.yml \
		--provenance-log=$@.provlog \
		--log-file=build/apply_$*.log \
		--log-level=INFO


${OUTDIR}/energy.pkl: data/gamma-diffuse_train_en.dl2.h5  train_energy_regressor.yml | ${OUTDIR}
	ctapipe-train-energy-regressor \
		-i $< --output=$@ \
		-c train_energy_regressor.yml \
		--provenance-log=$@.provlog \
		--log-file=build/train_energy.log \
		--log-level=INFO \
		--overwrite

${OUTDIR}/classifier.pkl: ${OUTDIR}/proton_train.dl2.h5 ${OUTDIR}/gamma-diffuse_train_clf.dl2.h5  train_particle_classifier.yml
	ctapipe-train-particle-classifier \
		-o $@ \
		--signal ${OUTDIR}/gamma-diffuse_train_clf.dl2.h5 \
		--background ${OUTDIR}/proton_train.dl2.h5 \
		-c train_particle_classifier.yml \
		--provenance-log=$@.provlog \
		--log-file=build/train_classifier.log \
		--log-level=INFO \
		--overwrite

${OUTDIR}/gamma-diffuse_train_clf.dl2.h5: data/gamma-diffuse_train_clf.dl2.h5 ${OUTDIR}/energy.pkl
	ctapipe-apply-models \
		-i $< -o $@ \
		--energy-regressor ${OUTDIR}/energy.pkl \
		-c apply_config.yml \
		--provenance-log=$@.provlog \
		--log-file=build/apply_gamma-diffuse_train_clf.log \
		--log-level=INFO

${OUTDIR}/proton_train.dl2.h5: data/proton_train.dl2.h5 ${OUTDIR}/energy.pkl
	ctapipe-apply-models \
		-i $< -o $@ \
		--energy-regressor ${OUTDIR}/energy.pkl \
		-c apply_config.yml \
		--provenance-log=$@.provlog \
		--log-file=build/apply_proton_train.log \
		--log-level=INFO


${OUTDIR}:
	mkdir -p ${OUTDIR}


clean:
	rm -rf ${OUTDIR}

.PHONY: all clean
.DELETE_ON_ERROR:
