`ifndef IOQJUGALNT
`define IOQJUGALNT

package jedec_p;

	//
	// Bus properties
	//

	localparam int unsigned DAT_WIDTH = 8;

	//
	// Registers
	//

	typedef struct packed {
		logic [0 : 0]   power_up_status;
		logic [30 : 29] access_mode;
		logic [28 : 24] reserved_b;
		logic [23 : 15] v2p7to3p6;
		logic [14 : 8]  v2p0to2p6;
		logic [0 : 0]   v1p70to1p95;
		logic [6 : 0]   reserved_a;
	} ocr_t;

	typedef struct packed {
		logic [7 : 0]   mid;
		logic [5 : 0]   reserved_a;
		logic [1 : 0]   cbx;
		logic [7 : 0]   oid;
		logic [47 : 0]  pnm;
		logic [7 : 0]   prv;
		logic [31 : 0]  psn;
		logic [7 : 0]   mdt;
		logic [6 : 0]   crc;
		logic [0 : 0]   reserved_b;
	} cid_t; // Card identification register

	typedef struct packed {
		logic [1 : 0]   csd_structure;
		logic [3 : 0]   spec_ver;
		logic [1 : 0]   reserved_c;
		logic [7 : 0]   taac;
		logic [7 : 0]   nsac;
		logic [7 : 0]   tran_speed;
		logic [11 : 0]  ccc;
		logic [3 : 0]   read_bl_len;
		logic [0 : 0]   read_bl_partial;
		logic [0 : 0]   write_blk_misalign;
		logic [0 : 0]   read_blk_misalign;
		logic [0 : 0]   dsr_imp;
		logic [1 : 0]   reserved_d;
		logic [11 : 0]  c_size;
		logic [2 : 0]   vdd_r_curr_min;
		logic [2 : 0]   vdd_r_curr_max;
		logic [2 : 0]   vdd_w_curr_min;
		logic [2 : 0]   vdd_w_curr_max;
		logic [2 : 0]   c_size_mult;
		logic [4 : 0]   erase_grp_size;
		logic [4 : 0]   erase_grp_mult;
		logic [4 : 0]   wp_grp_size;
		logic [0 : 0]   wp_grp_enable;
		logic [1 : 0]   default_ecc;
		logic [2 : 0]   r2w_factor;
		logic [3 : 0]   write_bl_len;
		logic [0 : 0]   write_bl_partial;
		logic [3 : 0]   reserved_e;
		logic [0 : 0]   content_prot_app;
		logic [0 : 0]   file_format_grp;
		logic [0 : 0]   copy;
		logic [0 : 0]   perm_write_protect;
		logic [0 : 0]   tmp_write_protect;
		logic [1 : 0]   file_format;
		logic [1 : 0]   ecc;
		logic [6 : 0]   crc;
		logic [0 : 0]   reserved_f;
	} csd_t;

	typedef struct packed {
		logic [5 : 0][7 : 0]   reserved_g;
		logic [0 : 0][7 : 0]   ext_security_err;
		logic [0 : 0][7 : 0]   s_cmd_set;
		logic [0 : 0][7 : 0]   hpi_features;
		logic [0 : 0][7 : 0]   bkops_support;
		logic [0 : 0][7 : 0]   max_packed_reads;
		logic [0 : 0][7 : 0]   max_packed_writes;
		logic [0 : 0][7 : 0]   data_tag_support;
		logic [0 : 0][7 : 0]   tag_unit_size;
		logic [0 : 0][7 : 0]   tag_res_size;
		logic [0 : 0][7 : 0]   context_capabilities;
		logic [0 : 0][7 : 0]   large_unit_size_m1;
		logic [0 : 0][7 : 0]   ext_support;
		logic [0 : 0][7 : 0]   supported_modes;
		logic [0 : 0][7 : 0]   ffu_features;
		logic [0 : 0][7 : 0]   operation_code_timeout;
		logic [3 : 0][7 : 0]   ffu_arg;
		logic [0 : 0][7 : 0]   barrier_support;
		logic [176 : 0][7 : 0] reserved_h;
		logic [0 : 0][7 : 0]   cmdq_support;
		logic [0 : 0][7 : 0]   cmdq_depth;
		logic [0 : 0][7 : 0]   reserved_i;
		logic [3 : 0][7 : 0]   number_of_fw_sectors_correctly_programmed;
		logic [31 : 0][7 : 0]  vendor_proprietary_health_report;
		logic [0 : 0][7 : 0]   device_life_time_est_typ_b;
		logic [0 : 0][7 : 0]   device_life_time_est_typ_a;
		logic [0 : 0][7 : 0]   pre_eol_info;
		logic [0 : 0][7 : 0]   optimal_read_size;
		logic [0 : 0][7 : 0]   optimal_write_size;
		logic [0 : 0][7 : 0]   optimal_trim_unit_size;
		logic [1 : 0][7 : 0]   device_version;
		logic [7 : 0][7 : 0]   firmware_version;
		logic [0 : 0][7 : 0]   pwr_cl_ddr_200_360;
		logic [3 : 0][7 : 0]   cache_size;
		logic [0 : 0][7 : 0]   generic_cmd6_time;
		logic [0 : 0][7 : 0]   power_off_long_time;
		logic [0 : 0][7 : 0]   bkops_status;
		logic [3 : 0][7 : 0]   correctly_prg_sectors_num;
		logic [0 : 0][7 : 0]   ini_timeout_ap;
		logic [0 : 0][7 : 0]   cache_flush_policy;
		logic [0 : 0][7 : 0]   pwr_cl_ddr_52_360;
		logic [0 : 0][7 : 0]   pwr_cl_ddr_52_195;
		logic [0 : 0][7 : 0]   pwr_cl_200_195;
		logic [0 : 0][7 : 0]   pwr_cl_200_130;
		logic [0 : 0][7 : 0]   min_perf_ddr_w_8_52;
		logic [0 : 0][7 : 0]   min_perf_ddr_r_8_52;
		logic [0 : 0][7 : 0]   reserved_j;
		logic [0 : 0][7 : 0]   trim_mult;
		logic [0 : 0][7 : 0]   sec_feature_support;
		logic [0 : 0][7 : 0]   sec_erase_mult;
		logic [0 : 0][7 : 0]   sec_trim_mult;
		logic [0 : 0][7 : 0]   boot_info;
		logic [0 : 0][7 : 0]   reserved_k;
		logic [0 : 0][7 : 0]   boot_size_mult;
		logic [0 : 0][7 : 0]   acc_size;
		logic [0 : 0][7 : 0]   hc_erase_grp_size;
		logic [0 : 0][7 : 0]   erase_timeout_mult;
		logic [0 : 0][7 : 0]   rel_wr_sec_c;
		logic [0 : 0][7 : 0]   hc_wp_grp_size;
		logic [0 : 0][7 : 0]   s_c_vcc;
		logic [0 : 0][7 : 0]   s_c_vccq;
		logic [0 : 0][7 : 0]   production_state_awareness_timeout;
		logic [0 : 0][7 : 0]   s_a_timeout;
		logic [0 : 0][7 : 0]   sleep_notification_time;
		logic [3 : 0][7 : 0]   sec_count;
		logic [0 : 0][7 : 0]   secure_wp_info;
		logic [0 : 0][7 : 0]   min_perf_w_8_52;
		logic [0 : 0][7 : 0]   min_perf_r_8_52;
		logic [0 : 0][7 : 0]   min_perf_w_8_26_4_52;
		logic [0 : 0][7 : 0]   min_perf_r_8_26_4_52;
		logic [0 : 0][7 : 0]   min_perf_w_4_26;
		logic [0 : 0][7 : 0]   min_perf_r_4_26;
		logic [0 : 0][7 : 0]   reserved_l;
		logic [0 : 0][7 : 0]   pwr_cl_26_360;
		logic [0 : 0][7 : 0]   pwr_cl_52_360;
		logic [0 : 0][7 : 0]   pwr_cl_26_195;
		logic [0 : 0][7 : 0]   pwr_cl_52_195;
		logic [0 : 0][7 : 0]   partition_switch_time;
		logic [0 : 0][7 : 0]   out_of_interrupt_time;
		logic [0 : 0][7 : 0]   driver_strength;
		logic [0 : 0][7 : 0]   device_type;
		logic [0 : 0][7 : 0]   reserved_m;
		logic [0 : 0][7 : 0]   csd_structure;
		logic [0 : 0][7 : 0]   reserved_n;
		logic [0 : 0][7 : 0]   ext_csd_rev;
		logic [0 : 0][7 : 0]   cmd_set;
		logic [0 : 0][7 : 0]   reserved_o;
		logic [0 : 0][7 : 0]   cmd_set_rev;
		logic [0 : 0][7 : 0]   reserved_p;
		logic [0 : 0][7 : 0]   power_class;
		logic [0 : 0][7 : 0]   reserved_q;
		logic [0 : 0][7 : 0]   hs_timing;
		logic [0 : 0][7 : 0]   strobe_support;
		logic [0 : 0][7 : 0]   bus_width;
		logic [0 : 0][7 : 0]   reserved_r;
		logic [0 : 0][7 : 0]   erased_mem_cont;
		logic [0 : 0][7 : 0]   reserved_s;
		logic [0 : 0][7 : 0]   partition_config;
		logic [0 : 0][7 : 0]   boot_config_prot;
		logic [0 : 0][7 : 0]   boot_bus_conditions;
		logic [0 : 0][7 : 0]   reserved_t;
		logic [0 : 0][7 : 0]   erase_group_def;
		logic [0 : 0][7 : 0]   boot_wp_status;
		logic [0 : 0][7 : 0]   boot_wp;
		logic [0 : 0][7 : 0]   reserved_u;
		logic [0 : 0][7 : 0]   user_wp;
		logic [0 : 0][7 : 0]   reserved_v;
		logic [0 : 0][7 : 0]   fw_config;
		logic [0 : 0][7 : 0]   rpmb_size_mult;
		logic [0 : 0][7 : 0]   wr_rel_set;
		logic [0 : 0][7 : 0]   wr_rel_param;
		logic [0 : 0][7 : 0]   sanitize_start;
		logic [0 : 0][7 : 0]   bkops_start;
		logic [0 : 0][7 : 0]   bkops_en;
		logic [0 : 0][7 : 0]   rst_n_function;
		logic [0 : 0][7 : 0]   hpi_mgmt;
		logic [0 : 0][7 : 0]   partitioning_support;
		logic [2 : 0][7 : 0]   max_enh_size_mult;
		logic [0 : 0][7 : 0]   partitions_attribute;
		logic [0 : 0][7 : 0]   partition_setting_completed;
		logic [2 : 0][7 : 0]   gp_size_mult_4;
		logic [2 : 0][7 : 0]   gp_size_mult_3;
		logic [2 : 0][7 : 0]   gp_size_mult_2;
		logic [2 : 0][7 : 0]   gp_size_mult_1;
		logic [2 : 0][7 : 0]   enh_size_mult;
		logic [3 : 0][7 : 0]   enh_start_addr;
		logic [0 : 0][7 : 0]   reserved_w;
		logic [0 : 0][7 : 0]   sec_bad_blk_mgmnt;
		logic [0 : 0][7 : 0]   production_state_awareness;
		logic [0 : 0][7 : 0]   tcase_support;
		logic [0 : 0][7 : 0]   periodic_wakeup;
		logic [0 : 0][7 : 0]   program_cid_csd_ddr_support;
		logic [1 : 0][7 : 0]   reserved_x;
		logic [63 : 0][7 : 0]  vendor_specific_field;
		logic [0 : 0][7 : 0]   native_sector_size;
		logic [0 : 0][7 : 0]   use_native_sector;
		logic [0 : 0][7 : 0]   data_sector_size;
		logic [0 : 0][7 : 0]   ini_timeout_emu;
		logic [0 : 0][7 : 0]   class_6_ctrl;
		logic [0 : 0][7 : 0]   dyncap_needed;
		logic [1 : 0][7 : 0]   exception_events_ctrl;
		logic [1 : 0][7 : 0]   exception_events_status;
		logic [1 : 0][7 : 0]   ext_partitions_attribute;
		logic [14 : 0][7 : 0]  context_conf;
		logic [0 : 0][7 : 0]   packed_command_status;
		logic [0 : 0][7 : 0]   packed_failure_index;
		logic [0 : 0][7 : 0]   power_off_notification;
		logic [0 : 0][7 : 0]   cache_ctrl;
		logic [0 : 0][7 : 0]   flush_cache;
		logic [0 : 0][7 : 0]   barrier_ctrl;
		logic [0 : 0][7 : 0]   mode_config;
		logic [0 : 0][7 : 0]   mode_operation_codes;
		logic [1 : 0][7 : 0]   reserved_y;
		logic [0 : 0][7 : 0]   ffu_status;
		logic [3 : 0][7 : 0]   pre_loading_data_size;
		logic [3 : 0][7 : 0]   max_pre_loading_data_size;
		logic [0 : 0][7 : 0]   product_state_awareness_enablement;
		logic [0 : 0][7 : 0]   secure_removal_type;
		logic [0 : 0][7 : 0]   cmdq_mode_en;
		logic [14 : 0][7 : 0]  reserved_z;
	} ext_csd_t;

	//
	// Widths of responses
	//

	localparam FULL_RESPONSE_WIDTH = 128;
	localparam R1_WIDTH = 32;
	localparam R2_WIDTH = 128;
	localparam R3_WIDTH = 32;
	// TODO: add these parameters:
	// localparam R4_WIDTH = ;
	// localparam R5_WIDTH = ;

	//
	// Other
	//

	typedef struct packed {
		logic [5 : 0] idx;
		logic [31 : 0] arg;
	} cmd_info_t;

	typedef struct packed {
		logic [31 : 26] set_to_0_a;
		logic [25 : 24] access;
		logic [23 : 16] index;
		logic [15 : 8]  value;
		logic [7 : 3]   set_to_0_b;
		logic [2 : 0]   cmd_set;
	} cmd6arg_t;

	typedef struct packed {
		logic         address_out_of_range;
		logic         address_misalign;
		logic         block_len_error;
		logic         erase_seq_error;
		logic         erase_param;
		logic         wp_violation;
		logic         card_is_locked;
		logic         lock_unlock_failed;
		logic         com_crc_error;
		logic         illegal_command;
		logic         card_ecc_failed;
		logic         cc_error;
		logic         error;
		logic         underrun;
		logic         overrun;
		logic         cidcsd_overwrite;
		logic         wp_erase_skip;
		logic         reserved_a;
		logic         erase_reset;
		logic [3 : 0] current_state;
		logic         ready_for_data;
		logic         switch_error;
		logic         urgent_bkops;
		logic         app_cmd;
		logic         reserved_b;
		logic [1 : 0] reserved_c;
		logic [1 : 0] reserved_d;
	} card_status_t;

	// Miscel

	localparam int unsigned BLK_CNT_WIDTH = 16;

endpackage

`endif