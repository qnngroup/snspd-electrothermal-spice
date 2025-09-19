# Electrothermal SPICE model of SNSPD

## SPICE models (`snspd_photon_port.lib`, 'snspd_photon_port.lib`)

### [SNSPD model with electrothermal feedback](https://arxiv.org/abs/2508.02791) uses an ancillary circuit to model Joule heating and thermal dissapation in the SNSPD. The model allows for simulating of device architectures such as thermally-coupled SNSPDs and thermal effects of SNAPs and PNR circuits in SPICE.
<img width="695" height="854" alt="image" src="https://github.com/user-attachments/assets/968a2918-c7fd-4f4e-95e9-f4888057ea79" />

### Model inputs
+ params: Lind=200n width=100n thickness=4n
+ sheetRes=300 Tb=2 Tc=10 Jc=50G Gv=1e-9 C=0.5
- Lind      : kinetic inductance (H)
- width:    : nanowire width (m)
- thickness : nanowire thickness (m)
- Jc        : critical current density at Tb (A/m^2)
- sheetRes  : sheet resistance (ohms/sq)
- Gv        : thermal boundary conductance (W/K^n)
- Tc        : critical temperature (K)
- Tb        : bath temperature (K)
- C         : constriction factor

### `snspd_photon_port.lib` 
This file includes 3 different models, each with varying levels of complexity:
- [`nanowireBCF`](https://iopscience.iop.org/article/10.1088/1361-6668/aab149) uses a basic curve fit model
- [`nanowireDynamic`](https://iopscience.iop.org/article/10.1088/1361-6668/aab149) uses a thermal boundary velocity model to capture the growth of a hotspot
- [`nanowireDynTherm`](https://arxiv.org/abs/2508.02791) uses both the thermal boundary velocity and electrothermal feedback equations to model macroscopic thermal dynamics in the wire

### `snspd_thermal_port.lib` 
This file includes 1 model `nanowire_thermal_port`, which is the same as `nanowireDynTherm`, except with an extra port to probe the temperature or couple the temperature of the wire externally to other nanowires.

### example circuits
- `snspd-thermal.asc`: models single pulses, multiple pulses, and latching be changing an external load resistance
- <img width="1913" height="860" alt="image" src="https://github.com/user-attachments/assets/af706231-600d-4142-8315-a2356a8e6d26" />
-  `pnr-thermal.asc`: models a photon-number resolving circuit using the electrothermal model up to 4 SNSPDS
-  <img width="1917" height="875" alt="image" src="https://github.com/user-attachments/assets/73de0e01-e64e-47e8-a97f-683dcc84aada" />
-  `SNAP-thermal.asc`: models a superconducting nanowire avalanche photon detector circuit using the electrothermal model up to 3 SNSPDs (3-SNAP)
-  <img width="1397" height="411" alt="image" src="https://github.com/user-attachments/assets/cf4baecd-f72f-4019-bc56-060caeee2bef" />
-  `snspd-thermal-coupling.asc`: models the thermal coupling of two SNSPDs for applciations such as [spatially resolved SNSPD arrays](https://pubs.acs.org/doi/10.1021/acs.nanolett.0c00246)
-  <img width="1916" height="870" alt="image" src="https://github.com/user-attachments/assets/ed7da681-1cc4-4221-bf41-d407b4dc83d1" />
