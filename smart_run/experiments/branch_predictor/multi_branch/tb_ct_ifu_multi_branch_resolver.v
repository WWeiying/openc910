`timescale 1ns/1ps

module tb_ct_ifu_multi_branch_resolver;

localparam PC_WIDTH = 16;
localparam GHR_WIDTH = 8;

reg                  block_valid;
reg                  branch0_valid;
reg                  branch0_pred_taken;
reg  [PC_WIDTH-1:0]  branch0_target;
reg                  branch1_valid;
reg                  branch1_context_valid;
reg                  branch1_pred_taken;
reg  [PC_WIDTH-1:0]  branch1_target;
reg                  branch2_or_more_valid;
reg  [GHR_WIDTH-1:0] vghr;
wire [1:0]           consumed_cond_branches;
wire                 second_prediction_consumed;
wire                 redirect_valid;
wire                 redirect_from_branch1;
wire [PC_WIDTH-1:0]  redirect_target;
wire [GHR_WIDTH-1:0] next_vghr;
wire                 replay_required;
wire [1:0]           tail_select;

ct_ifu_multi_branch_resolver #(
  .PC_WIDTH  (PC_WIDTH),
  .GHR_WIDTH (GHR_WIDTH)
) dut (
  .block_valid                 (block_valid),
  .branch0_valid               (branch0_valid),
  .branch0_pred_taken          (branch0_pred_taken),
  .branch0_target              (branch0_target),
  .branch1_valid               (branch1_valid),
  .branch1_context_valid       (branch1_context_valid),
  .branch1_pred_taken          (branch1_pred_taken),
  .branch1_target              (branch1_target),
  .branch2_or_more_valid       (branch2_or_more_valid),
  .vghr                        (vghr),
  .consumed_cond_branches      (consumed_cond_branches),
  .second_prediction_consumed  (second_prediction_consumed),
  .redirect_valid              (redirect_valid),
  .redirect_from_branch1       (redirect_from_branch1),
  .redirect_target             (redirect_target),
  .next_vghr                   (next_vghr),
  .replay_required             (replay_required),
  .tail_select                 (tail_select)
);

task check;
  input [1:0] expected_consumed;
  input       expected_redirect;
  input       expected_redirect_from_branch1;
  input       expected_replay;
  input [1:0] expected_tail;
  input [GHR_WIDTH-1:0] expected_vghr;
  begin
    #1;
    if (consumed_cond_branches !== expected_consumed
        || redirect_valid !== expected_redirect
        || redirect_from_branch1 !== expected_redirect_from_branch1
        || replay_required !== expected_replay
        || tail_select !== expected_tail
        || next_vghr !== expected_vghr) begin
      $display("FAIL consumed=%0d redirect=%0d from1=%0d replay=%0d tail=%0d vghr=%h",
               consumed_cond_branches, redirect_valid,
               redirect_from_branch1, replay_required, tail_select, next_vghr);
      $fatal(1);
    end
  end
endtask

initial begin
  block_valid = 1'b0;
  branch0_valid = 1'b0;
  branch0_pred_taken = 1'b0;
  branch0_target = 16'h1000;
  branch1_valid = 1'b0;
  branch1_context_valid = 1'b0;
  branch1_pred_taken = 1'b0;
  branch1_target = 16'h2000;
  branch2_or_more_valid = 1'b0;
  vghr = 8'b1010_1101;
  check(2'd0, 1'b0, 1'b0, 1'b0, 2'd0, 8'b1010_1101);

  block_valid = 1'b1;
  branch0_valid = 1'b1;
  check(2'd1, 1'b0, 1'b0, 1'b0, 2'd0, 8'b0101_1010);

  branch0_pred_taken = 1'b1;
  branch1_valid = 1'b1;
  branch1_context_valid = 1'b1;
  check(2'd1, 1'b1, 1'b0, 1'b0, 2'd1, 8'b0101_1011);
  if (redirect_target !== branch0_target)
    $fatal(1, "branch0 target selection failed");

  branch0_pred_taken = 1'b0;
  branch1_context_valid = 1'b0;
  check(2'd1, 1'b0, 1'b0, 1'b1, 2'd1, 8'b0101_1010);

  branch1_context_valid = 1'b1;
  branch1_pred_taken = 1'b0;
  check(2'd2, 1'b0, 1'b0, 1'b0, 2'd0, 8'b1011_0100);

  branch1_pred_taken = 1'b1;
  check(2'd2, 1'b1, 1'b1, 1'b0, 2'd2, 8'b1011_0101);
  if (redirect_target !== branch1_target)
    $fatal(1, "branch1 target selection failed");

  branch1_pred_taken = 1'b0;
  branch2_or_more_valid = 1'b1;
  check(2'd2, 1'b0, 1'b0, 1'b1, 2'd2, 8'b1011_0100);

  $display("PASS ct_ifu_multi_branch_resolver");
  $finish;
end

endmodule
