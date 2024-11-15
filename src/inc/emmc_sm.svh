`ifndef MTGWDPADIP
`define MTGWDPADIP

`include "jedec.svh"

package emmc_sm_p;

	typedef enum {
		START,
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
		DO_WRITE,
		DO_READ,
		DO_NOTHING,
		IDLE,
		ERR
	} state_t;

endpackage

`endif
