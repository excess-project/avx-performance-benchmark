#!/bin/sh -f
DIR_NOW=`pwd`
PERF_DIR=${DIR_NOW}/../data
ENERGY_DIR=${DIR_NOW}/../energy_data
POWER_CALCULATE_BIN=${DIR_NOW}/power_calculate_avx
CONFIG_FILE=${DIR_NOW}/tools/config_components_node01.ini
TOPDIR=/nas_home/hpcfapix/hpcfapix/measure/57916.fe.excess-project.eu/

rm -rf ${ENERGY_DIR}
mkdir ${ENERGY_DIR}

module load compiler/gnu/4.9.2

#sequential add:
POWER_CALCULATE_BIN -verbosity 1 -offset_sec 0.0 -relative_time 0 -board_id 2 -config_file "${CONFIG_FILE}" -topdir "${TOPDIR}" -performance_file "${PERF_DIR}/seq_1cores.dat" -power_file "${ENERGY_DIR}/seq_power.dat" -energy_file "${ENERGY_DIR}/seq_energy.dat" -joule_per_flop_file "${ENERGY_DIR}/seq_joule_per_flop.dat"

#fixed increment add:
POWER_CALCULATE_BIN -verbosity 1 -offset_sec 0.0 -relative_time 0 -board_id 2 -config_file "${CONFIG_FILE}" -topdir "${TOPDIR}" -performance_file "${PERF_DIR}/incre_1cores.dat" -power_file "${ENERGY_DIR}/incre_power.dat" -energy_file "${ENERGY_DIR}/incre_energy.dat" -joule_per_flop_file "${ENERGY_DIR}/incre_joule_per_flop.dat"

#list add:
POWER_CALCULATE_BIN -verbosity 1 -offset_sec 0.0 -relative_time 0 -board_id 2 -config_file "${CONFIG_FILE}" -topdir "${TOPDIR}" -performance_file "${PERF_DIR}/list_1cores.dat" -power_file "${ENERGY_DIR}/list_power.dat" -energy_file "${ENERGY_DIR}/list_energy.dat" -joule_per_flop_file "${ENERGY_DIR}/list_joule_per_flop.dat"

#random index add:
POWER_CALCULATE_BIN -verbosity 1 -offset_sec 0.0 -relative_time 0 -board_id 2 -config_file "${CONFIG_FILE}" -topdir "${TOPDIR}" -performance_file "${PERF_DIR}/randidx_1cores.dat" -power_file "${ENERGY_DIR}/randidx_power.dat" -energy_file "${ENERGY_DIR}/randidx_energy.dat" -joule_per_flop_file "${ENERGY_DIR}/randidx_joule_per_flop.dat"

#para_pin1 add:
#1 core
POWER_CALCULATE_BIN -verbosity 1 -offset_sec 0.0 -relative_time 0 -board_id 2 -config_file "${CONFIG_FILE}" -topdir "${TOPDIR}" -performance_file "${PERF_DIR}/para_pin1_1cores.dat" -power_file "${ENERGY_DIR}/para_pin1_1power.dat" -energy_file "${ENERGY_DIR}/para_pin1_1energy.dat" -joule_per_flop_file "${ENERGY_DIR}/para_pin1_1joule_per_flop.dat"

#2 core
POWER_CALCULATE_BIN -verbosity 1 -offset_sec 0.0 -relative_time 0 -board_id 2 -config_file "${CONFIG_FILE}" -topdir "${TOPDIR}" -performance_file "${PERF_DIR}/para_pin1_2cores.dat" -power_file "${ENERGY_DIR}/para_pin1_2power.dat" -energy_file "${ENERGY_DIR}/para_pin1_2energy.dat" -joule_per_flop_file "${ENERGY_DIR}/para_pin1_2joule_per_flop.dat"

#4 core
POWER_CALCULATE_BIN -verbosity 1 -offset_sec 0.0 -relative_time 0 -board_id 2 -config_file "${CONFIG_FILE}" -topdir "${TOPDIR}" -performance_file "${PERF_DIR}/para_pin1_4cores.dat" -power_file "${ENERGY_DIR}/para_pin1_4power.dat" -energy_file "${ENERGY_DIR}/para_pin1_4energy.dat" -joule_per_flop_file "${ENERGY_DIR}/para_pin1_4joule_per_flop.dat"

#6 core
POWER_CALCULATE_BIN -verbosity 1 -offset_sec 0.0 -relative_time 0 -board_id 2 -config_file "${CONFIG_FILE}" -topdir "${TOPDIR}" -performance_file "${PERF_DIR}/para_pin1_6cores.dat" -power_file "${ENERGY_DIR}/para_pin1_6power.dat" -energy_file "${ENERGY_DIR}/para_pin1_6energy.dat" -joule_per_flop_file "${ENERGY_DIR}/para_pin1_6joule_per_flop.dat"

#para_pin2 add:
#1 core
POWER_CALCULATE_BIN -verbosity 1 -offset_sec 0.0 -relative_time 0 -board_id 2 -config_file "${CONFIG_FILE}" -topdir "${TOPDIR}" -performance_file "${PERF_DIR}/para_pin2_1cores.dat" -power_file "${ENERGY_DIR}/para_pin2_1power.dat" -energy_file "${ENERGY_DIR}/para_pin2_1energy.dat" -joule_per_flop_file "${ENERGY_DIR}/para_pin2_1joule_per_flop.dat"

#2 core
POWER_CALCULATE_BIN -verbosity 1 -offset_sec 0.0 -relative_time 0 -board_id 2 -config_file "${CONFIG_FILE}" -topdir "${TOPDIR}" -performance_file "${PERF_DIR}/para_pin2_2cores.dat" -power_file "${ENERGY_DIR}/para_pin2_2power.dat" -energy_file "${ENERGY_DIR}/para_pin2_2energy.dat" -joule_per_flop_file "${ENERGY_DIR}/para_pin2_2joule_per_flop.dat"

#4 core
POWER_CALCULATE_BIN -verbosity 1 -offset_sec 0.0 -relative_time 0 -board_id 2 -config_file "${CONFIG_FILE}" -topdir "${TOPDIR}" -performance_file "${PERF_DIR}/para_pin2_4cores.dat" -power_file "${ENERGY_DIR}/para_pin2_4power.dat" -energy_file "${ENERGY_DIR}/para_pin2_4energy.dat" -joule_per_flop_file "${ENERGY_DIR}/para_pin2_4joule_per_flop.dat"

#6 core
POWER_CALCULATE_BIN -verbosity 1 -offset_sec 0.0 -relative_time 0 -board_id 2 -config_file "${CONFIG_FILE}" -topdir "${TOPDIR}" -performance_file "${PERF_DIR}/para_pin2_6cores.dat" -power_file "${ENERGY_DIR}/para_pin2_6power.dat" -energy_file "${ENERGY_DIR}/para_pin2_6energy.dat" -joule_per_flop_file "${ENERGY_DIR}/para_pin2_6joule_per_flop.dat"

