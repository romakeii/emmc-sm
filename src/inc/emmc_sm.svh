`ifndef MTGWDPADIP
`define MTGWDPADIP

`include "jedec.svh"

package emmc_sm_p;

	typedef enum {
		INIT_START,
		WAIT_CMD,
		WAIT_DAT,
		WAIT_BUSY,
		INIT_IDLE,
		INIT_READY,
		INIT_IDENT,
		INIT_STBY,
		INIT_GET_CSD,
		INIT_TRAN,
		INIT_GET_CSD_EXT,
		INIT_GO_FAST,
		INIT_SET_DWIDTH,
		DO_IDLE,
		DO_SBLK_WRITE,
		DO_SBLK_READ,
		DO_MBLK_WRITE,
		DO_MBLK_READ,
		DO_STOP_TRANSACT,
		DO_NOTHING,
		IDLE,
		ERR
	} state_t;

endpackage

`endif
