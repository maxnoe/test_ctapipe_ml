OUTDIR=build


all: ${OUTDIR}/gamma-diffuse_eval.dl2.h5 ${OUTDIR}/proton_eval.dl2.h5


${OUTDIR}/%_eval.dl2.h5: data/%_eval.dl2.h5 ${OUTDIR}/energy.pkl ${OUTDIR}/classifier.pkl apply_config.yaml
	ctapipe-apply-models \
		-i $< -o $@ \
		--regressor ${OUTDIR}/energy.pkl \
		--classifier ${OUTDIR}/classifier.pkl \
		-c apply_config.yaml \
		--provenance-log=$@.provlog \
		--log-file=build/apply_$*.log \
		--log-level=INFO


${OUTDIR}/energy.pkl: data/gamma-diffuse_train_en.dl2.h5  ml_config.yaml | ${OUTDIR}
	ctapipe-train-regressor \
		-i $< -o $@ \
		-c ml_config.yaml \
		--provenance-log=$@.provlog \
		--log-file=build/train_energy.log \
		--log-level=INFO

${OUTDIR}/classifier.pkl: ${OUTDIR}/proton_train.dl2.h5 ${OUTDIR}/gamma-diffuse_train_clf.dl2.h5  ml_config.yaml
	ctapipe-train-classifier \
		-o $@ \
		--signal ${OUTDIR}/gamma-diffuse_train_clf.dl2.h5 \
		--background ${OUTDIR}/proton_train.dl2.h5 \
		-c ml_config.yaml \
		--provenance-log=$@.provlog \
		--log-file=build/train_classifier.log \
		--log-level=INFO

${OUTDIR}/gamma-diffuse_train_clf.dl2.h5: data/gamma-diffuse_train_clf.dl2.h5 ${OUTDIR}/energy.pkl
	ctapipe-apply-models \
		-i $< -o $@ \
		--regressor ${OUTDIR}/energy.pkl \
		-c apply_config.yaml \
		--provenance-log=$@.provlog \
		--log-file=build/apply_gamma-diffuse_train_clf.log \
		--log-level=INFO

${OUTDIR}/proton_train.dl2.h5: data/proton_train.dl2.h5 ${OUTDIR}/energy.pkl
	ctapipe-apply-models \
		-i $< -o $@ \
		--regressor ${OUTDIR}/energy.pkl \
		-c apply_config.yaml \
		--provenance-log=$@.provlog \
		--log-file=build/apply_proton_train.log \
		--log-level=INFO


${OUTDIR}:
	mkdir -p ${OUTDIR}


clean:
	rm -rf ${OUTDIR}

.PHONY: all clean
.DELETE_ON_ERROR:
