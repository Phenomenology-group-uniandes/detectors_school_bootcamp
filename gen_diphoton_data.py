import os
import subprocess

import pandas as pd
from ROOT import TChain

from hep_pheno_tools.abstract_particle import Particle, get_kinematics_row
from hep_pheno_tools.analysis_tools import Quiet, generate_dataframe
from hep_pheno_tools.delphes_reader.classifier import get_photons
from hep_pheno_tools.delphes_reader.loader import DelphesLoader


class PhotonParticle(Particle):
    def __init__(self, event, j):
        super().__init__()
        self.tlv.SetPtEtaPhiM(
            event.GetLeaf("Photon.PT").GetValue(j),
            event.GetLeaf("Photon.Eta").GetValue(j),
            event.GetLeaf("Photon.Phi").GetValue(j),
            0,
        )
        self.charge = 0
        self.kind = "photon"
        self.name = f"{self.kind}_{{{j}}}"

        self.isolation = event.GetLeaf("Photon.IsolationVar").GetValue(j)


run_mg5 = True
if run_mg5:
    subprocess.call(["mg5_aMC", "diphoton.mg5"])


df_paths = pd.DataFrame(columns=["name", "path", "xs(pb)"])

path_signal = os.path.join(os.getcwd(), "diphoton_higgs")
path_bkg = os.path.join(os.getcwd(), "diphoton_higgs_bkg")

xs_signal = 0.004991  # pb
xs_bkg = 4.047  # pb

df_paths = df_paths.from_dict(
    {
        "name": ["signal", "bkg"],
        "path": [path_signal, path_bkg],
        "xs(pb)": [xs_signal, xs_bkg],
    }
)

df_paths.to_csv("paths.csv", index=False)


distributions = {}
with Quiet():
    for sim in ["signal", "bkg"]:
        reader = DelphesLoader(sim, path="paths.csv")
        kin_results = []
        for root_file in reader.Forest:
            tree = TChain("Delphes;1")
            tree.Add(root_file)

            for event in tree:
                photons = get_photons(event)
                if len(photons) != 2:
                    continue
                row = get_kinematics_row(photons)
                kin_results.append(row)
        df = pd.DataFrame.from_records(kin_results)
        df.to_csv(os.path.join("data_test", f"{sim}.csv"), index=False)
        print(f"Number of events for {sim}: {len(kin_results)}")
