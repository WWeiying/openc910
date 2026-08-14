`timescale 1ns/1ps

/*
 * Ordered two-conditional-branch resolver prototype.
 *
 * This module is intentionally not connected to ct_ifu_top.  It specifies the
 * control contract required by a future two-wide IP/BHT implementation.  The
 * caller must provide an independent, history-correct prediction context for
 * branch1; reusing branch0's BHT metadata is not valid.
 */
module ct_ifu_multi_branch_resolver #(
  parameter PC_WIDTH  = 39,
  parameter GHR_WIDTH = 22
)(
  input                   block_valid,
  input                   branch0_valid,
  input                   branch0_pred_taken,
  input  [PC_WIDTH-1:0]   branch0_target,
  input                   branch1_valid,
  input                   branch1_context_valid,
  input                   branch1_pred_taken,
  input  [PC_WIDTH-1:0]   branch1_target,
  input                   branch2_or_more_valid,
  input  [GHR_WIDTH-1:0]  vghr,
  output [1:0]            consumed_cond_branches,
  output                  second_prediction_consumed,
  output                  redirect_valid,
  output                  redirect_from_branch1,
  output [PC_WIDTH-1:0]   redirect_target,
  output [GHR_WIDTH-1:0]  next_vghr,
  output                  replay_required,
  output [1:0]            tail_select
);

function [GHR_WIDTH-1:0] append_history;
  input [GHR_WIDTH-1:0] history;
  input                 outcome;
  begin
    append_history = {history[GHR_WIDTH-2:0], outcome};
  end
endfunction

wire consume_branch0;
wire consume_branch1;
wire branch1_waits_for_context;

assign consume_branch0 = block_valid && branch0_valid;
assign consume_branch1 = consume_branch0
                         && !branch0_pred_taken
                         && branch1_valid
                         && branch1_context_valid;
assign branch1_waits_for_context = consume_branch0
                                   && !branch0_pred_taken
                                   && branch1_valid
                                   && !branch1_context_valid;

assign consumed_cond_branches = consume_branch1 ? 2'd2
                                                : consume_branch0 ? 2'd1
                                                                  : 2'd0;
assign second_prediction_consumed = consume_branch1;

/* Program order is strict: branch1 is reachable only when branch0 predicts NT. */
assign redirect_valid = consume_branch0
                        && (branch0_pred_taken
                            || (consume_branch1 && branch1_pred_taken));
assign redirect_from_branch1 = consume_branch1 && branch1_pred_taken;
assign redirect_target = redirect_from_branch1 ? branch1_target
                                               : branch0_target;

/* Speculative history advances once per prediction, in program order. */
assign next_vghr = consume_branch1
                   ? append_history(
                       append_history(vghr, branch0_pred_taken),
                       branch1_pred_taken
                     )
                   : consume_branch0
                     ? append_history(vghr, branch0_pred_taken)
                     : vghr;

/*
 * tail_select:
 *   0: no truncation is required;
 *   1: truncate after branch0;
 *   2: truncate after branch1.
 *
 * A missing branch1 context falls back to the native one-wide replay path.
 */
assign tail_select = branch0_pred_taken && consume_branch0 ? 2'd1
                   : branch1_waits_for_context             ? 2'd1
                   : consume_branch1
                     && (branch1_pred_taken || branch2_or_more_valid) ? 2'd2
                                                                     : 2'd0;

assign replay_required = branch1_waits_for_context
                         || (consume_branch1
                             && !branch1_pred_taken
                             && branch2_or_more_valid);

endmodule
