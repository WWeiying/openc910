
dhrystone.elf:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <__start>:
       0:	004001b7          	lui	gp,0x400
       4:	7c01a073          	csrs	mxstatus,gp
       8:	6199                	lui	gp,0x6
       a:	3001a073          	csrs	mstatus,gp
       e:	008001b7          	lui	gp,0x800
      12:	3001a073          	csrs	mstatus,gp
      16:	61a1                	lui	gp,0x8
      18:	7c01a073          	csrs	mxstatus,gp
      1c:	006381b7          	lui	gp,0x638
      20:	7c01a073          	csrs	mxstatus,gp
      24:	7f30e073          	csrsi	msmpr,1
      28:	4081                	li	ra,0
      2a:	4101                	li	sp,0
      2c:	4181                	li	gp,0
      2e:	4201                	li	tp,0
      30:	4281                	li	t0,0
      32:	4301                	li	t1,0
      34:	4381                	li	t2,0
      36:	4401                	li	s0,0
      38:	4481                	li	s1,0
      3a:	4501                	li	a0,0
      3c:	4581                	li	a1,0
      3e:	4601                	li	a2,0
      40:	4681                	li	a3,0
      42:	4701                	li	a4,0
      44:	4781                	li	a5,0
      46:	4801                	li	a6,0
      48:	4881                	li	a7,0
      4a:	4901                	li	s2,0
      4c:	4981                	li	s3,0
      4e:	4a01                	li	s4,0
      50:	4a81                	li	s5,0
      52:	4b01                	li	s6,0
      54:	4b81                	li	s7,0
      56:	4c01                	li	s8,0
      58:	4c81                	li	s9,0
      5a:	4d01                	li	s10,0
      5c:	4d81                	li	s11,0
      5e:	4e01                	li	t3,0
      60:	4e81                	li	t4,0
      62:	4f01                	li	t5,0
      64:	4f81                	li	t6,0
      66:	f14021f3          	csrr	gp,mhartid
      6a:	4205                	li	tp,1

000000000000006c <cpu_0_sp>:
      6c:	000ee117          	auipc	sp,0xee
      70:	f9410113          	addi	sp,sp,-108 # ee000 <__kernel_stack>
      74:	00000197          	auipc	gp,0x0
      78:	08a18193          	addi	gp,gp,138 # fe <__trap_handler>
      7c:	30519073          	csrw	mtvec,gp
      80:	41a1                	li	gp,8
      82:	3001a073          	csrs	mstatus,gp
      86:	000701b7          	lui	gp,0x70
      8a:	21cd                	addiw	gp,gp,19 # 70013 <heap_end.0+0x2c763>
      8c:	7c21a073          	csrs	mcor,gp
      90:	6185                	lui	gp,0x1
      92:	1ff1819b          	addiw	gp,gp,511 # 11ff <_ftoa+0x37f>
      96:	7c11a073          	csrs	mhcr,gp

000000000000009a <after_l2en>:
      9a:	6185                	lui	gp,0x1
      9c:	1ff1819b          	addiw	gp,gp,511 # 11ff <_ftoa+0x37f>
      a0:	7c11a073          	csrs	mhcr,gp
      a4:	0006e1b7          	lui	gp,0x6e
      a8:	30c1819b          	addiw	gp,gp,780 # 6e30c <heap_end.0+0x2aa5c>
      ac:	7c51a073          	csrs	mhint,gp
      b0:	0070019b          	addiw	gp,zero,7
      b4:	01f6                	slli	gp,gp,0x1d
      b6:	01a5                	addi	gp,gp,9
      b8:	7c31a073          	csrs	mccr2,gp
      bc:	764000ef          	jal	820 <main>

00000000000000c0 <__exit>:
      c0:	4501                	li	a0,0
      c2:	05a00093          	li	ra,90
      c6:	06b00113          	li	sp,107
      ca:	07c00193          	li	gp,124
      ce:	0180000b          	th.sync
      d2:	004441b7          	lui	gp,0x444
      d6:	3331819b          	addiw	gp,gp,819 # 444333 <__kernel_stack+0x356333>
      da:	01b2                	slli	gp,gp,0xc
      dc:	22218193          	addi	gp,gp,546
      e0:	820e                	mv	tp,gp

00000000000000e2 <__fail>:
      e2:	4501                	li	a0,0
      e4:	02c00093          	li	ra,44
      e8:	03b00113          	li	sp,59
      ec:	0180000b          	th.sync
      f0:	004701b7          	lui	gp,0x470
      f4:	4691819b          	addiw	gp,gp,1129 # 470469 <__kernel_stack+0x382469>
      f8:	01be                	slli	gp,gp,0xf
      fa:	72018193          	addi	gp,gp,1824

00000000000000fe <__trap_handler>:
      fe:	a03d                	j	12c <__synchronous_exception>
     100:	a085                	j	160 <__asychronous_int>
     102:	0001                	nop
     104:	0001                	nop
     106:	0001                	nop
     108:	a8a1                	j	160 <__asychronous_int>
     10a:	0001                	nop
     10c:	a891                	j	160 <__asychronous_int>
     10e:	0001                	nop
     110:	a881                	j	160 <__asychronous_int>
     112:	0001                	nop
     114:	0001                	nop
     116:	0001                	nop
     118:	a0a1                	j	160 <__asychronous_int>
     11a:	0001                	nop
     11c:	a091                	j	160 <__asychronous_int>
     11e:	0001                	nop
     120:	a081                	j	160 <__asychronous_int>
     122:	0001                	nop
     124:	0001                	nop
     126:	0001                	nop
     128:	a825                	j	160 <__asychronous_int>
     12a:	bf65                	j	e2 <__fail>

000000000000012c <__synchronous_exception>:
     12c:	fed12e23          	sw	a3,-4(sp)
     130:	fee12c23          	sw	a4,-8(sp)
     134:	fef12a23          	sw	a5,-12(sp)
     138:	34202773          	csrr	a4,mcause
     13c:	7ff77793          	andi	a5,a4,2047
     140:	936d                	srli	a4,a4,0x3b
     142:	8b41                	andi	a4,a4,16
     144:	973e                	add	a4,a4,a5
     146:	070e                	slli	a4,a4,0x3
     148:	00000797          	auipc	a5,0x0
     14c:	2b878793          	addi	a5,a5,696 # 400 <vector_table>
     150:	97ba                	add	a5,a5,a4
     152:	4398                	lw	a4,0(a5)
     154:	ffc12683          	lw	a3,-4(sp)
     158:	ff412783          	lw	a5,-12(sp)
     15c:	1771                	addi	a4,a4,-4
     15e:	8702                	jr	a4

0000000000000160 <__asychronous_int>:
     160:	fed12e23          	sw	a3,-4(sp)
     164:	fee12c23          	sw	a4,-8(sp)
     168:	fef12a23          	sw	a5,-12(sp)
     16c:	34202773          	csrr	a4,mcause
     170:	7ff77793          	andi	a5,a4,2047
     174:	936d                	srli	a4,a4,0x3b
     176:	8b41                	andi	a4,a4,16
     178:	973e                	add	a4,a4,a5
     17a:	070e                	slli	a4,a4,0x3
     17c:	00000797          	auipc	a5,0x0
     180:	28478793          	addi	a5,a5,644 # 400 <vector_table>
     184:	97ba                	add	a5,a5,a4
     186:	4398                	lw	a4,0(a5)
     188:	ffc12683          	lw	a3,-4(sp)
     18c:	ff412783          	lw	a5,-12(sp)
     190:	1771                	addi	a4,a4,-4
     192:	8702                	jr	a4
     194:	00000013          	nop
     198:	00000013          	nop
     19c:	00000013          	nop
     1a0:	00000013          	nop
     1a4:	00000013          	nop
     1a8:	00000013          	nop
     1ac:	00000013          	nop
     1b0:	00000013          	nop
     1b4:	00000013          	nop
     1b8:	00000013          	nop
     1bc:	00000013          	nop
     1c0:	00000013          	nop
     1c4:	00000013          	nop
     1c8:	00000013          	nop
     1cc:	00000013          	nop
     1d0:	00000013          	nop
     1d4:	00000013          	nop
     1d8:	00000013          	nop
     1dc:	00000013          	nop
     1e0:	00000013          	nop
     1e4:	00000013          	nop
     1e8:	00000013          	nop
     1ec:	00000013          	nop
     1f0:	00000013          	nop
     1f4:	00000013          	nop
     1f8:	00000013          	nop
     1fc:	00000013          	nop
     200:	00000013          	nop
     204:	00000013          	nop
     208:	00000013          	nop
     20c:	00000013          	nop
     210:	00000013          	nop
     214:	00000013          	nop
     218:	00000013          	nop
     21c:	00000013          	nop
     220:	00000013          	nop
     224:	00000013          	nop
     228:	00000013          	nop
     22c:	00000013          	nop
     230:	00000013          	nop
     234:	00000013          	nop
     238:	00000013          	nop
     23c:	00000013          	nop
     240:	00000013          	nop
     244:	00000013          	nop
     248:	00000013          	nop
     24c:	00000013          	nop
     250:	00000013          	nop
     254:	00000013          	nop
     258:	00000013          	nop
     25c:	00000013          	nop
     260:	00000013          	nop
     264:	00000013          	nop
     268:	00000013          	nop
     26c:	00000013          	nop
     270:	00000013          	nop
     274:	00000013          	nop
     278:	00000013          	nop
     27c:	00000013          	nop
     280:	00000013          	nop
     284:	00000013          	nop
     288:	00000013          	nop
     28c:	00000013          	nop
     290:	00000013          	nop
     294:	00000013          	nop
     298:	00000013          	nop
     29c:	00000013          	nop
     2a0:	00000013          	nop
     2a4:	00000013          	nop
     2a8:	00000013          	nop
     2ac:	00000013          	nop
     2b0:	00000013          	nop
     2b4:	00000013          	nop
     2b8:	00000013          	nop
     2bc:	00000013          	nop
     2c0:	00000013          	nop
     2c4:	00000013          	nop
     2c8:	00000013          	nop
     2cc:	00000013          	nop
     2d0:	00000013          	nop
     2d4:	00000013          	nop
     2d8:	00000013          	nop
     2dc:	00000013          	nop
     2e0:	00000013          	nop
     2e4:	00000013          	nop
     2e8:	00000013          	nop
     2ec:	00000013          	nop
     2f0:	00000013          	nop
     2f4:	00000013          	nop
     2f8:	00000013          	nop
     2fc:	00000013          	nop
     300:	00000013          	nop
     304:	00000013          	nop
     308:	00000013          	nop
     30c:	00000013          	nop
     310:	00000013          	nop
     314:	00000013          	nop
     318:	00000013          	nop
     31c:	00000013          	nop
     320:	00000013          	nop
     324:	00000013          	nop
     328:	00000013          	nop
     32c:	00000013          	nop
     330:	00000013          	nop
     334:	00000013          	nop
     338:	00000013          	nop
     33c:	00000013          	nop
     340:	00000013          	nop
     344:	00000013          	nop
     348:	00000013          	nop
     34c:	00000013          	nop
     350:	00000013          	nop
     354:	00000013          	nop
     358:	00000013          	nop
     35c:	00000013          	nop
     360:	00000013          	nop
     364:	00000013          	nop
     368:	00000013          	nop
     36c:	00000013          	nop
     370:	00000013          	nop
     374:	00000013          	nop
     378:	00000013          	nop
     37c:	00000013          	nop
     380:	00000013          	nop
     384:	00000013          	nop
     388:	00000013          	nop
     38c:	00000013          	nop
     390:	00000013          	nop
     394:	00000013          	nop
     398:	00000013          	nop
     39c:	00000013          	nop
     3a0:	00000013          	nop
     3a4:	00000013          	nop
     3a8:	00000013          	nop
     3ac:	00000013          	nop
     3b0:	00000013          	nop
     3b4:	00000013          	nop
     3b8:	00000013          	nop
     3bc:	00000013          	nop
     3c0:	00000013          	nop
     3c4:	00000013          	nop
     3c8:	00000013          	nop
     3cc:	00000013          	nop
     3d0:	00000013          	nop
     3d4:	00000013          	nop
     3d8:	00000013          	nop
     3dc:	00000013          	nop
     3e0:	00000013          	nop
     3e4:	00000013          	nop
     3e8:	00000013          	nop
     3ec:	00000013          	nop
     3f0:	00000013          	nop
     3f4:	00000013          	nop
     3f8:	00000013          	nop
     3fc:	00000013          	nop

0000000000000400 <vector_table>:
     400:	000000e2          	.word	0x000000e2
     404:	000000e2          	.word	0x000000e2
     408:	000000e2          	.word	0x000000e2
     40c:	000000e2          	.word	0x000000e2
     410:	000000e2          	.word	0x000000e2
     414:	000000e2          	.word	0x000000e2
     418:	000000e2          	.word	0x000000e2
     41c:	000000e2          	.word	0x000000e2
     420:	000000e2          	.word	0x000000e2
     424:	000000e2          	.word	0x000000e2
     428:	000000e2          	.word	0x000000e2
     42c:	000000e2          	.word	0x000000e2
     430:	000000e2          	.word	0x000000e2
     434:	000000e2          	.word	0x000000e2
     438:	000000e2          	.word	0x000000e2
     43c:	000000e2          	.word	0x000000e2
     440:	000000e2          	.word	0x000000e2
     444:	000000e2          	.word	0x000000e2
     448:	000000e2          	.word	0x000000e2
     44c:	000000e2          	.word	0x000000e2
     450:	000000e2          	.word	0x000000e2
     454:	000000e2          	.word	0x000000e2
     458:	000000e2          	.word	0x000000e2
     45c:	000000e2          	.word	0x000000e2
     460:	000000e2          	.word	0x000000e2
     464:	000000e2          	.word	0x000000e2
     468:	000000e2          	.word	0x000000e2
     46c:	000000e2          	.word	0x000000e2
     470:	000000e2          	.word	0x000000e2
     474:	000000e2          	.word	0x000000e2
     478:	000000e2          	.word	0x000000e2
     47c:	000000e2          	.word	0x000000e2
     480:	000000e2          	.word	0x000000e2
     484:	000000e2          	.word	0x000000e2
     488:	000000e2          	.word	0x000000e2
     48c:	000000e2          	.word	0x000000e2
     490:	000000e2          	.word	0x000000e2
     494:	000000e2          	.word	0x000000e2
     498:	000000e2          	.word	0x000000e2
     49c:	000000e2          	.word	0x000000e2
     4a0:	000000e2          	.word	0x000000e2
     4a4:	000000e2          	.word	0x000000e2
     4a8:	000000e2          	.word	0x000000e2
     4ac:	000000e2          	.word	0x000000e2
     4b0:	000000e2          	.word	0x000000e2
     4b4:	000000e2          	.word	0x000000e2
     4b8:	000000e2          	.word	0x000000e2
     4bc:	000000e2          	.word	0x000000e2
     4c0:	000000e2          	.word	0x000000e2
     4c4:	000000e2          	.word	0x000000e2
     4c8:	000000e2          	.word	0x000000e2
     4cc:	000000e2          	.word	0x000000e2
     4d0:	000000e2          	.word	0x000000e2
     4d4:	000000e2          	.word	0x000000e2
     4d8:	000000e2          	.word	0x000000e2
     4dc:	000000e2          	.word	0x000000e2
     4e0:	000000e2          	.word	0x000000e2
     4e4:	000000e2          	.word	0x000000e2
     4e8:	000000e2          	.word	0x000000e2
     4ec:	000000e2          	.word	0x000000e2
     4f0:	000000e2          	.word	0x000000e2
     4f4:	000000e2          	.word	0x000000e2
     4f8:	000000e2          	.word	0x000000e2
     4fc:	000000e2          	.word	0x000000e2
     500:	000000e2          	.word	0x000000e2
     504:	000000e2          	.word	0x000000e2
     508:	000000e2          	.word	0x000000e2
     50c:	000000e2          	.word	0x000000e2
     510:	000000e2          	.word	0x000000e2
     514:	000000e2          	.word	0x000000e2
     518:	000000e2          	.word	0x000000e2
     51c:	000000e2          	.word	0x000000e2
     520:	000000e2          	.word	0x000000e2
     524:	000000e2          	.word	0x000000e2
     528:	000000e2          	.word	0x000000e2
     52c:	000000e2          	.word	0x000000e2
     530:	000000e2          	.word	0x000000e2
     534:	000000e2          	.word	0x000000e2
     538:	000000e2          	.word	0x000000e2
     53c:	000000e2          	.word	0x000000e2
     540:	000000e2          	.word	0x000000e2
     544:	000000e2          	.word	0x000000e2
     548:	000000e2          	.word	0x000000e2
     54c:	000000e2          	.word	0x000000e2
     550:	000000e2          	.word	0x000000e2
     554:	000000e2          	.word	0x000000e2
     558:	000000e2          	.word	0x000000e2
     55c:	000000e2          	.word	0x000000e2
     560:	000000e2          	.word	0x000000e2
     564:	000000e2          	.word	0x000000e2
     568:	000000e2          	.word	0x000000e2
     56c:	000000e2          	.word	0x000000e2
     570:	000000e2          	.word	0x000000e2
     574:	000000e2          	.word	0x000000e2
     578:	000000e2          	.word	0x000000e2
     57c:	000000e2          	.word	0x000000e2
     580:	000000e2          	.word	0x000000e2
     584:	000000e2          	.word	0x000000e2
     588:	000000e2          	.word	0x000000e2
     58c:	000000e2          	.word	0x000000e2
     590:	000000e2          	.word	0x000000e2
     594:	000000e2          	.word	0x000000e2
     598:	000000e2          	.word	0x000000e2
     59c:	000000e2          	.word	0x000000e2
     5a0:	000000e2          	.word	0x000000e2
     5a4:	000000e2          	.word	0x000000e2
     5a8:	000000e2          	.word	0x000000e2
     5ac:	000000e2          	.word	0x000000e2
     5b0:	000000e2          	.word	0x000000e2
     5b4:	000000e2          	.word	0x000000e2
     5b8:	000000e2          	.word	0x000000e2
     5bc:	000000e2          	.word	0x000000e2
     5c0:	000000e2          	.word	0x000000e2
     5c4:	000000e2          	.word	0x000000e2
     5c8:	000000e2          	.word	0x000000e2
     5cc:	000000e2          	.word	0x000000e2
     5d0:	000000e2          	.word	0x000000e2
     5d4:	000000e2          	.word	0x000000e2
     5d8:	000000e2          	.word	0x000000e2
     5dc:	000000e2          	.word	0x000000e2
     5e0:	000000e2          	.word	0x000000e2
     5e4:	000000e2          	.word	0x000000e2
     5e8:	000000e2          	.word	0x000000e2
     5ec:	000000e2          	.word	0x000000e2
     5f0:	000000e2          	.word	0x000000e2
     5f4:	000000e2          	.word	0x000000e2
     5f8:	000000e2          	.word	0x000000e2
     5fc:	000000e2          	.word	0x000000e2

0000000000000600 <__dummy>:
	...

0000000000000670 <__thead_vprintfsprintf>:
     670:	4501                	li	a0,0
     672:	8082                	ret
     674:	00000013          	nop
     678:	00000013          	nop
     67c:	00000013          	nop

0000000000000680 <__thead_vprintfprintf>:
     680:	4501                	li	a0,0
     682:	8082                	ret
     684:	00000013          	nop
     688:	00000013          	nop
     68c:	00000013          	nop

0000000000000690 <stdout>:
     690:	4501                	li	a0,0
     692:	8082                	ret
	...

00000000000006a0 <Proc_1>:
     6a0:	1101                	addi	sp,sp,-32
     6a2:	f891590b          	th.sdd	s2,s1,(sp),0,4
     6a6:	00041937          	lui	s2,0x41
     6aa:	f9090913          	addi	s2,s2,-112 # 40f90 <Next_Ptr_Glob>
     6ae:	04093783          	ld	a5,64(s2)
     6b2:	fa11540b          	th.sdd	s0,ra,(sp),1,4
     6b6:	6100                	ld	s0,0(a0)
     6b8:	f907c88b          	th.ldd	a7,a6,(a5),0,4
     6bc:	fcd7c60b          	th.ldd	a2,a3,(a5),2,4
     6c0:	7b98                	ld	a4,48(a5)
     6c2:	84aa                	mv	s1,a0
     6c4:	fab7c50b          	th.ldd	a0,a1,(a5),1,4
     6c8:	f904588b          	th.sdd	a7,a6,(s0),0,4
     6cc:	0004b303          	ld	t1,0(s1)
     6d0:	fab4550b          	th.sdd	a0,a1,(s0),1,4
     6d4:	fcd4560b          	th.sdd	a2,a3,(s0),2,4
     6d8:	4295                	li	t0,5
     6da:	f818                	sd	a4,48(s0)
     6dc:	0054a823          	sw	t0,16(s1)
     6e0:	00643023          	sd	t1,0(s0)
     6e4:	0007b383          	ld	t2,0(a5)
     6e8:	16892583          	lw	a1,360(s2)
     6ec:	4529                	li	a0,10
     6ee:	00743023          	sd	t2,0(s0)
     6f2:	04093e03          	ld	t3,64(s2)
     6f6:	00542823          	sw	t0,16(s0)
     6fa:	010e0613          	addi	a2,t3,16
     6fe:	642000ef          	jal	d40 <Proc_7>
     702:	00842e83          	lw	t4,8(s0)
     706:	020e8963          	beqz	t4,738 <Proc_1+0x98>
     70a:	0004bf03          	ld	t5,0(s1)
     70e:	fa11440b          	th.ldd	s0,ra,(sp),1,4
     712:	fcbf450b          	th.ldd	a0,a1,(t5),2,4
     716:	f92f4f8b          	th.ldd	t6,s2,(t5),0,4
     71a:	fb0f488b          	th.ldd	a7,a6,(t5),1,4
     71e:	030f3783          	ld	a5,48(t5)
     722:	fcb4d50b          	th.sdd	a0,a1,(s1),2,4
     726:	f924df8b          	th.sdd	t6,s2,(s1),0,4
     72a:	fb04d88b          	th.sdd	a7,a6,(s1),1,4
     72e:	f89c                	sd	a5,48(s1)
     730:	f891490b          	th.ldd	s2,s1,(sp),0,4
     734:	6105                	addi	sp,sp,32
     736:	8082                	ret
     738:	44c8                	lw	a0,12(s1)
     73a:	4619                	li	a2,6
     73c:	00c40593          	addi	a1,s0,12
     740:	c810                	sw	a2,16(s0)
     742:	5ae000ef          	jal	cf0 <Proc_6>
     746:	04093683          	ld	a3,64(s2)
     74a:	4808                	lw	a0,16(s0)
     74c:	8622                	mv	a2,s0
     74e:	6298                	ld	a4,0(a3)
     750:	fa11440b          	th.ldd	s0,ra,(sp),1,4
     754:	f891490b          	th.ldd	s2,s1,(sp),0,4
     758:	7a86570b          	th.sdia	a4,(a2),8,1
     75c:	45a9                	li	a1,10
     75e:	6105                	addi	sp,sp,32
     760:	5e00006f          	j	d40 <Proc_7>
     764:	00000013          	nop
     768:	00000013          	nop
     76c:	00000013          	nop

0000000000000770 <Proc_2>:
     770:	000417b7          	lui	a5,0x41
     774:	f9078293          	addi	t0,a5,-112 # 40f90 <Next_Ptr_Glob>
     778:	0902c683          	lbu	a3,144(t0)
     77c:	04100713          	li	a4,65
     780:	00e68463          	beq	a3,a4,788 <Proc_2+0x18>
     784:	8082                	ret
     786:	0001                	nop
     788:	00052303          	lw	t1,0(a0)
     78c:	1682a583          	lw	a1,360(t0)
     790:	0093039b          	addiw	t2,t1,9
     794:	40b3863b          	subw	a2,t2,a1
     798:	c110                	sw	a2,0(a0)
     79a:	8082                	ret
     79c:	00000013          	nop

00000000000007a0 <Proc_3>:
     7a0:	000417b7          	lui	a5,0x41
     7a4:	f9078293          	addi	t0,a5,-112 # 40f90 <Next_Ptr_Glob>
     7a8:	0402b603          	ld	a2,64(t0)
     7ac:	c609                	beqz	a2,7b6 <Proc_3+0x16>
     7ae:	6218                	ld	a4,0(a2)
     7b0:	e118                	sd	a4,0(a0)
     7b2:	0402b603          	ld	a2,64(t0)
     7b6:	1682a583          	lw	a1,360(t0)
     7ba:	0641                	addi	a2,a2,16
     7bc:	4529                	li	a0,10
     7be:	5820006f          	j	d40 <Proc_7>
     7c2:	0001                	nop
     7c4:	00000013          	nop
     7c8:	00000013          	nop
     7cc:	00000013          	nop

00000000000007d0 <Proc_4>:
     7d0:	000417b7          	lui	a5,0x41
     7d4:	f9078293          	addi	t0,a5,-112 # 40f90 <Next_Ptr_Glob>
     7d8:	0902c703          	lbu	a4,144(t0)
     7dc:	0942a683          	lw	a3,148(t0)
     7e0:	04200593          	li	a1,66
     7e4:	fbf70313          	addi	t1,a4,-65
     7e8:	00133393          	seqz	t2,t1
     7ec:	0076e533          	or	a0,a3,t2
     7f0:	08a2aa23          	sw	a0,148(t0)
     7f4:	08b28c23          	sb	a1,152(t0)
     7f8:	8082                	ret
     7fa:	00000013          	nop
     7fe:	0001                	nop

0000000000000800 <Proc_5>:
     800:	000417b7          	lui	a5,0x41
     804:	f9078293          	addi	t0,a5,-112 # 40f90 <Next_Ptr_Glob>
     808:	04100713          	li	a4,65
     80c:	08e28823          	sb	a4,144(t0)
     810:	0802aa23          	sw	zero,148(t0)
     814:	8082                	ret
	...

0000000000000820 <main>:
     820:	7155                	addi	sp,sp,-208
     822:	6529                	lui	a0,0xa
     824:	f54e                	sd	s3,168(sp)
     826:	f94a                	sd	s2,176(sp)
     828:	fd26                	sd	s1,184(sp)
     82a:	e1a2                	sd	s0,192(sp)
     82c:	43050913          	addi	s2,a0,1072 # a430 <__errno+0x184>
     830:	00041437          	lui	s0,0x41
     834:	f9040413          	addi	s0,s0,-112 # 40f90 <Next_Ptr_Glob>
     838:	e109488b          	th.lwd	a7,a6,(s2),0,3
     83c:	e2b9498b          	th.lwd	s3,a1,(s2),1,3
     840:	e4d9460b          	th.lwd	a2,a3,(s2),2,3
     844:	e586                	sd	ra,200(sp)
     846:	f4ee                	sd	s11,104(sp)
     848:	f8ea                	sd	s10,112(sp)
     84a:	fce6                	sd	s9,120(sp)
     84c:	e162                	sd	s8,128(sp)
     84e:	e55e                	sd	s7,136(sp)
     850:	e95a                	sd	s6,144(sp)
     852:	ed56                	sd	s5,152(sp)
     854:	f152                	sd	s4,160(sp)
     856:	4285                	li	t0,1
     858:	87a2                	mv	a5,s0
     85a:	00840713          	addi	a4,s0,8
     85e:	01892a03          	lw	s4,24(s2)
     862:	7e97d70b          	th.sdia	a4,(a5),9,3
     866:	02129313          	slli	t1,t0,0x21
     86a:	02800393          	li	t2,40
     86e:	6c29                	lui	s8,0xa
     870:	05142e23          	sw	a7,92(s0)
     874:	07042023          	sw	a6,96(s0)
     878:	d470                	sw	a2,108(s0)
     87a:	d834                	sw	a3,112(s0)
     87c:	450c0c93          	addi	s9,s8,1104 # a450 <__errno+0x1a4>
     880:	e03c                	sd	a5,64(s0)
     882:	e438                	sd	a4,72(s0)
     884:	04643823          	sd	t1,80(s0)
     888:	04742c23          	sw	t2,88(s0)
     88c:	07342223          	sw	s3,100(s0)
     890:	d42c                	sw	a1,104(s0)
     892:	07442a23          	sw	s4,116(s0)
     896:	010cbe03          	ld	t3,16(s9)
     89a:	018cae83          	lw	t4,24(s9)
     89e:	01ccdf03          	lhu	t5,28(s9)
     8a2:	01eccf83          	lbu	t6,30(s9)
     8a6:	01c95a83          	lhu	s5,28(s2)
     8aa:	01e94b03          	lbu	s6,30(s2)
     8ae:	f9bccd0b          	th.ldd	s10,s11,(s9),0,4
     8b2:	44a9                	li	s1,10
     8b4:	00041bb7          	lui	s7,0x41
     8b8:	118b8713          	addi	a4,s7,280 # 41118 <Arr_2_Glob>
     8bc:	8526                	mv	a0,s1
     8be:	f872                	sd	t3,48(sp)
     8c0:	dc76                	sw	t4,56(sp)
     8c2:	03e11e23          	sh	t5,60(sp)
     8c6:	03f10f23          	sb	t6,62(sp)
     8ca:	64972e23          	sw	s1,1628(a4)
     8ce:	07541c23          	sh	s5,120(s0)
     8d2:	07640d23          	sb	s6,122(s0)
     8d6:	fdb15d0b          	th.sdd	s10,s11,(sp),2,4
     8da:	526080ef          	jal	8e00 <putchar>
     8de:	67a9                	lui	a5,0xa
     8e0:	2b878513          	addi	a0,a5,696 # a2b8 <__errno+0xc>
     8e4:	48c080ef          	jal	8d70 <puts>
     8e8:	8526                	mv	a0,s1
     8ea:	516080ef          	jal	8e00 <putchar>
     8ee:	08042283          	lw	t0,128(s0)
     8f2:	2e028e63          	beqz	t0,bee <perf_monitor_end+0x174>
     8f6:	63a9                	lui	t2,0xa
     8f8:	2f038513          	addi	a0,t2,752 # a2f0 <__errno+0x44>
     8fc:	474080ef          	jal	8d70 <puts>
     900:	8526                	mv	a0,s1
     902:	4fe080ef          	jal	8e00 <putchar>
     906:	4529                	li	a0,10
     908:	4f8080ef          	jal	8e00 <putchar>
     90c:	64a9                	lui	s1,0xa
     90e:	3e800593          	li	a1,1000
     912:	35048513          	addi	a0,s1,848 # a350 <__errno+0xa4>
     916:	50a080ef          	jal	8e20 <printf>
     91a:	357080ef          	jal	9470 <get_vtimer>
     91e:	7c05350b          	th.extu	a0,a0,31,0
     922:	e448                	sd	a0,136(s0)

0000000000000924 <perf_monitor_start>:
     924:	68a9                	lui	a7,0xa
     926:	47088a13          	addi	s4,a7,1136 # a470 <__errno+0x1c4>
     92a:	f99a4d0b          	th.ldd	s10,s9,(s4),0,4
     92e:	010a3c03          	ld	s8,16(s4)
     932:	00041837          	lui	a6,0x41
     936:	69a9                	lui	s3,0xa
     938:	4905                	li	s2,1
     93a:	03080b13          	addi	s6,a6,48 # 41030 <Arr_1_Glob>
     93e:	04100a93          	li	s5,65
     942:	4b098493          	addi	s1,s3,1200 # a4b0 <__errno+0x204>
     946:	0001                	nop
     948:	01ea4e03          	lbu	t3,30(s4)
     94c:	018a2683          	lw	a3,24(s4)
     950:	01ca5d83          	lhu	s11,28(s4)
     954:	04200593          	li	a1,66
     958:	4605                	li	a2,1
     95a:	08b40c23          	sb	a1,152(s0)
     95e:	1008                	addi	a0,sp,32
     960:	008c                	addi	a1,sp,64
     962:	05c10f23          	sb	t3,94(sp)
     966:	ccb6                	sw	a3,88(sp)
     968:	ce32                	sw	a2,28(sp)
     96a:	e0ea                	sd	s10,64(sp)
     96c:	e4e6                	sd	s9,72(sp)
     96e:	05b11e23          	sh	s11,92(sp)
     972:	08c42a23          	sw	a2,148(s0)
     976:	09540823          	sb	s5,144(s0)
     97a:	e8e2                	sd	s8,80(sp)
     97c:	454000ef          	jal	dd0 <Func_2>
     980:	00153e93          	seqz	t4,a0
     984:	4f1d                	li	t5,7
     986:	0830                	addi	a2,sp,24
     988:	458d                	li	a1,3
     98a:	4509                	li	a0,2
     98c:	cc7a                	sw	t5,24(sp)
     98e:	09d42a23          	sw	t4,148(s0)
     992:	3ae000ef          	jal	d40 <Proc_7>
     996:	46e2                	lw	a3,24(sp)
     998:	460d                	li	a2,3
     99a:	118b8593          	addi	a1,s7,280
     99e:	855a                	mv	a0,s6
     9a0:	3b0000ef          	jal	d50 <Proc_8>
     9a4:	04043983          	ld	s3,64(s0)
     9a8:	4895                	li	a7,5
     9aa:	16842583          	lw	a1,360(s0)
     9ae:	f9f9cd8b          	th.ldd	s11,t6,(s3),0,4
     9b2:	fa59c78b          	th.ldd	a5,t0,(s3),1,4
     9b6:	fc79c30b          	th.ldd	t1,t2,(s3),2,4
     9ba:	0309b703          	ld	a4,48(s3)
     9be:	864e                	mv	a2,s3
     9c0:	f9fddd8b          	th.sdd	s11,t6,(s11),0,4
     9c4:	7a86480b          	th.ldia	a6,(a2),8,1
     9c8:	fa5dd78b          	th.sdd	a5,t0,(s11),1,4
     9cc:	fc7dd30b          	th.sdd	t1,t2,(s11),2,4
     9d0:	02edb823          	sd	a4,48(s11)
     9d4:	0119a823          	sw	a7,16(s3)
     9d8:	4529                	li	a0,10
     9da:	011da823          	sw	a7,16(s11)
     9de:	010db023          	sd	a6,0(s11)
     9e2:	35e000ef          	jal	d40 <Proc_7>
     9e6:	008da503          	lw	a0,8(s11)
     9ea:	1c050563          	beqz	a0,bb4 <perf_monitor_end+0x13a>
     9ee:	0009be03          	ld	t3,0(s3)
     9f2:	09844303          	lbu	t1,152(s0)
     9f6:	04000393          	li	t2,64
     9fa:	f9ee4e8b          	th.ldd	t4,t5,(t3),0,4
     9fe:	face458b          	th.ldd	a1,a2,(t3),1,4
     a02:	fdbe468b          	th.ldd	a3,s11,(t3),2,4
     a06:	030e3f83          	ld	t6,48(t3)
     a0a:	f9e9de8b          	th.sdd	t4,t5,(s3),0,4
     a0e:	fac9d58b          	th.sdd	a1,a2,(s3),1,4
     a12:	fdb9d68b          	th.sdd	a3,s11,(s3),2,4
     a16:	03f9b823          	sd	t6,48(s3)
     a1a:	1c63f863          	bgeu	t2,t1,bea <perf_monitor_end+0x170>
     a1e:	04100d93          	li	s11,65
     a22:	498d                	li	s3,3
     a24:	00000013          	nop
     a28:	04300593          	li	a1,67
     a2c:	856e                	mv	a0,s11
     a2e:	382000ef          	jal	db0 <Func_1>
     a32:	4772                	lw	a4,28(sp)
     a34:	12a70e63          	beq	a4,a0,b70 <perf_monitor_end+0xf6>
     a38:	09844803          	lbu	a6,152(s0)
     a3c:	001d889b          	addiw	a7,s11,1
     a40:	0ff8fd93          	zext.b	s11,a7
     a44:	ffb872e3          	bgeu	a6,s11,a28 <perf_monitor_start+0x104>
     a48:	0019979b          	slliw	a5,s3,0x1
     a4c:	013789bb          	addw	s3,a5,s3
     a50:	4362                	lw	t1,24(sp)
     a52:	09044283          	lbu	t0,144(s0)
     a56:	0269cdbb          	divw	s11,s3,t1
     a5a:	88ee                	mv	a7,s11
     a5c:	01529863          	bne	t0,s5,a6c <perf_monitor_start+0x148>
     a60:	16842703          	lw	a4,360(s0)
     a64:	009d839b          	addiw	t2,s11,9
     a68:	40e388bb          	subw	a7,t2,a4
     a6c:	2905                	addiw	s2,s2,1
     a6e:	3e900813          	li	a6,1001
     a72:	ed091be3          	bne	s2,a6,948 <perf_monitor_start+0x24>
     a76:	f911530b          	th.sdd	t1,a7,(sp),0,4

0000000000000a7a <perf_monitor_end>:
     a7a:	6a29                	lui	s4,0xa
     a7c:	1f5080ef          	jal	9470 <get_vtimer>
     a80:	7c053b8b          	th.extu	s7,a0,31,0
     a84:	380a0513          	addi	a0,s4,896 # a380 <__errno+0xd4>
     a88:	17743823          	sd	s7,368(s0)
     a8c:	2e4080ef          	jal	8d70 <puts>
     a90:	6444                	ld	s1,136(s0)
     a92:	17043d03          	ld	s10,368(s0)
     a96:	6e29                	lui	t3,0xa
     a98:	6c29                	lui	s8,0xa
     a9a:	4f0c2787          	flw	fa5,1264(s8) # a4f0 <__errno+0x244>
     a9e:	4f4e2087          	flw	ft1,1268(t3) # a4f4 <__errno+0x248>
     aa2:	409d0cb3          	sub	s9,s10,s1
     aa6:	d02cf753          	fcvt.s.l	fa4,s9
     aaa:	6aa9                	lui	s5,0xa
     aac:	18f77053          	fdiv.s	ft0,fa4,fa5
     ab0:	390a8513          	addi	a0,s5,912 # a390 <__errno+0xe4>
     ab4:	17943c23          	sd	s9,376(s0)
     ab8:	6b29                	lui	s6,0xa
     aba:	18e0f153          	fdiv.s	ft2,ft1,fa4
     abe:	18042027          	fsw	ft0,384(s0)
     ac2:	18242227          	fsw	ft2,388(s0)
     ac6:	35a080ef          	jal	8e20 <printf>
     aca:	18042187          	flw	ft3,384(s0)
     ace:	3c0b0513          	addi	a0,s6,960 # a3c0 <__errno+0x114>
     ad2:	42018253          	fcvt.d.s	ft4,ft3
     ad6:	e20205d3          	fmv.x.d	a1,ft4
     ada:	346080ef          	jal	8e20 <printf>
     ade:	6529                	lui	a0,0xa
     ae0:	3c850513          	addi	a0,a0,968 # a3c8 <__errno+0x11c>
     ae4:	33c080ef          	jal	8e20 <printf>
     ae8:	18442287          	flw	ft5,388(s0)
     aec:	3c0b0513          	addi	a0,s6,960
     af0:	42028353          	fcvt.d.s	ft6,ft5
     af4:	e20305d3          	fmv.x.d	a1,ft6
     af8:	328080ef          	jal	8e20 <printf>
     afc:	6ea9                	lui	t4,0xa
     afe:	3f8e8513          	addi	a0,t4,1016 # a3f8 <__errno+0x14c>
     b02:	31e080ef          	jal	8e20 <printf>
     b06:	6f29                	lui	t5,0xa
     b08:	18442387          	flw	ft7,388(s0)
     b0c:	4f8f2507          	flw	fa0,1272(t5) # a4f8 <__errno+0x24c>
     b10:	6629                	lui	a2,0xa
     b12:	42860513          	addi	a0,a2,1064 # a428 <__errno+0x17c>
     b16:	18a3f5d3          	fdiv.s	fa1,ft7,fa0
     b1a:	42058653          	fcvt.d.s	fa2,fa1
     b1e:	e20605d3          	fmv.x.d	a1,fa2
     b22:	2fe080ef          	jal	8e20 <printf>
     b26:	4529                	li	a0,10
     b28:	2d8080ef          	jal	8e00 <putchar>
     b2c:	16842583          	lw	a1,360(s0)
     b30:	4695                	li	a3,5
     b32:	00d59763          	bne	a1,a3,b40 <perf_monitor_end+0xc6>
     b36:	09442783          	lw	a5,148(s0)
     b3a:	4f85                	li	t6,1
     b3c:	0df78263          	beq	a5,t6,c00 <perf_monitor_end+0x186>
     b40:	64a9                	lui	s1,0xa
     b42:	4a048513          	addi	a0,s1,1184 # a4a0 <__errno+0x1f4>
     b46:	22a080ef          	jal	8d70 <puts>
     b4a:	137080ef          	jal	9480 <sim_end>
     b4e:	60ae                	ld	ra,200(sp)
     b50:	74ea                	ld	s1,184(sp)
     b52:	640e                	ld	s0,192(sp)
     b54:	7da6                	ld	s11,104(sp)
     b56:	7d46                	ld	s10,112(sp)
     b58:	7ce6                	ld	s9,120(sp)
     b5a:	6c0a                	ld	s8,128(sp)
     b5c:	6baa                	ld	s7,136(sp)
     b5e:	6b4a                	ld	s6,144(sp)
     b60:	6aea                	ld	s5,152(sp)
     b62:	7a0a                	ld	s4,160(sp)
     b64:	79aa                	ld	s3,168(sp)
     b66:	794a                	ld	s2,176(sp)
     b68:	4501                	li	a0,0
     b6a:	6169                	addi	sp,sp,208
     b6c:	8082                	ret
     b6e:	0001                	nop
     b70:	086c                	addi	a1,sp,28
     b72:	4501                	li	a0,0
     b74:	17c000ef          	jal	cf0 <Proc_6>
     b78:	f9d4ce0b          	th.ldd	t3,t4,(s1),0,4
     b7c:	0104bf03          	ld	t5,16(s1)
     b80:	4c8c                	lw	a1,24(s1)
     b82:	01c4d603          	lhu	a2,28(s1)
     b86:	01e4c683          	lbu	a3,30(s1)
     b8a:	09844f83          	lbu	t6,152(s0)
     b8e:	001d851b          	addiw	a0,s11,1
     b92:	e0f2                	sd	t3,64(sp)
     b94:	e4f6                	sd	t4,72(sp)
     b96:	0ff57d93          	zext.b	s11,a0
     b9a:	e8fa                	sd	t5,80(sp)
     b9c:	ccae                	sw	a1,88(sp)
     b9e:	04c11e23          	sh	a2,92(sp)
     ba2:	04d10f23          	sb	a3,94(sp)
     ba6:	17242423          	sw	s2,360(s0)
     baa:	89ca                	mv	s3,s2
     bac:	e7bffee3          	bgeu	t6,s11,a28 <perf_monitor_start+0x104>
     bb0:	bd61                	j	a48 <perf_monitor_start+0x124>
     bb2:	0001                	nop
     bb4:	00c9a503          	lw	a0,12(s3)
     bb8:	4799                	li	a5,6
     bba:	00cd8593          	addi	a1,s11,12
     bbe:	00fda823          	sw	a5,16(s11)
     bc2:	12e000ef          	jal	cf0 <Proc_6>
     bc6:	04043983          	ld	s3,64(s0)
     bca:	010da503          	lw	a0,16(s11)
     bce:	866e                	mv	a2,s11
     bd0:	0009b283          	ld	t0,0(s3)
     bd4:	45a9                	li	a1,10
     bd6:	7a86528b          	th.sdia	t0,(a2),8,1
     bda:	166000ef          	jal	d40 <Proc_7>
     bde:	09844303          	lbu	t1,152(s0)
     be2:	04000393          	li	t2,64
     be6:	e263ece3          	bltu	t2,t1,a1e <perf_monitor_start+0xfa>
     bea:	49a5                	li	s3,9
     bec:	b595                	j	a50 <perf_monitor_start+0x12c>
     bee:	6329                	lui	t1,0xa
     bf0:	32030513          	addi	a0,t1,800 # a320 <__errno+0x74>
     bf4:	17c080ef          	jal	8d70 <puts>
     bf8:	8526                	mv	a0,s1
     bfa:	206080ef          	jal	8e00 <putchar>
     bfe:	b321                	j	906 <main+0xe6>
     c00:	09044283          	lbu	t0,144(s0)
     c04:	04100313          	li	t1,65
     c08:	f2629ce3          	bne	t0,t1,b40 <perf_monitor_end+0xc6>
     c0c:	09844383          	lbu	t2,152(s0)
     c10:	04200713          	li	a4,66
     c14:	f2e396e3          	bne	t2,a4,b40 <perf_monitor_end+0xc6>
     c18:	0c042903          	lw	s2,192(s0)
     c1c:	489d                	li	a7,7
     c1e:	f31911e3          	bne	s2,a7,b40 <perf_monitor_end+0xc6>
     c22:	00041837          	lui	a6,0x41
     c26:	11880b93          	addi	s7,a6,280 # 41118 <Arr_2_Glob>
     c2a:	65cbaa03          	lw	s4,1628(s7)
     c2e:	3f200b13          	li	s6,1010
     c32:	f16a17e3          	bne	s4,s6,b40 <perf_monitor_end+0xc6>
     c36:	04043d03          	ld	s10,64(s0)
     c3a:	4a85                	li	s5,1
     c3c:	021a9493          	slli	s1,s5,0x21
     c40:	008d3c83          	ld	s9,8(s10)
     c44:	ee9c9ee3          	bne	s9,s1,b40 <perf_monitor_end+0xc6>
     c48:	010d2e03          	lw	t3,16(s10)
     c4c:	4c45                	li	s8,17
     c4e:	ef8e19e3          	bne	t3,s8,b40 <perf_monitor_end+0xc6>
     c52:	6529                	lui	a0,0xa
     c54:	43050593          	addi	a1,a0,1072 # a430 <__errno+0x184>
     c58:	014d0513          	addi	a0,s10,20
     c5c:	705080ef          	jal	9b60 <strcmp>
     c60:	ee0510e3          	bnez	a0,b40 <perf_monitor_end+0xc6>
     c64:	6000                	ld	s0,0(s0)
     c66:	4e85                	li	t4,1
     c68:	020e9f13          	slli	t5,t4,0x20
     c6c:	6410                	ld	a2,8(s0)
     c6e:	ede619e3          	bne	a2,t5,b40 <perf_monitor_end+0xc6>
     c72:	480c                	lw	a1,16(s0)
     c74:	46c9                	li	a3,18
     c76:	ecd595e3          	bne	a1,a3,b40 <perf_monitor_end+0xc6>
     c7a:	6fa9                	lui	t6,0xa
     c7c:	430f8593          	addi	a1,t6,1072 # a430 <__errno+0x184>
     c80:	01440513          	addi	a0,s0,20
     c84:	6dd080ef          	jal	9b60 <strcmp>
     c88:	ea051ce3          	bnez	a0,b40 <perf_monitor_end+0xc6>
     c8c:	f8f1430b          	th.ldd	t1,a5,(sp),0,4
     c90:	4295                	li	t0,5
     c92:	ea5797e3          	bne	a5,t0,b40 <perf_monitor_end+0xc6>
     c96:	406989bb          	subw	s3,s3,t1
     c9a:	439d                	li	t2,7
     c9c:	0333873b          	mulw	a4,t2,s3
     ca0:	48b5                	li	a7,13
     ca2:	41b70dbb          	subw	s11,a4,s11
     ca6:	e91d9de3          	bne	s11,a7,b40 <perf_monitor_end+0xc6>
     caa:	4862                	lw	a6,24(sp)
     cac:	491d                	li	s2,7
     cae:	e92819e3          	bne	a6,s2,b40 <perf_monitor_end+0xc6>
     cb2:	4a72                	lw	s4,28(sp)
     cb4:	4b85                	li	s7,1
     cb6:	e97a15e3          	bne	s4,s7,b40 <perf_monitor_end+0xc6>
     cba:	6b29                	lui	s6,0xa
     cbc:	450b0593          	addi	a1,s6,1104 # a450 <__errno+0x1a4>
     cc0:	1008                	addi	a0,sp,32
     cc2:	69f080ef          	jal	9b60 <strcmp>
     cc6:	e6051de3          	bnez	a0,b40 <perf_monitor_end+0xc6>
     cca:	6aa9                	lui	s5,0xa
     ccc:	470a8593          	addi	a1,s5,1136 # a470 <__errno+0x1c4>
     cd0:	0088                	addi	a0,sp,64
     cd2:	68f080ef          	jal	9b60 <strcmp>
     cd6:	e60515e3          	bnez	a0,b40 <perf_monitor_end+0xc6>
     cda:	6d29                	lui	s10,0xa
     cdc:	490d0513          	addi	a0,s10,1168 # a490 <__errno+0x1e4>
     ce0:	090080ef          	jal	8d70 <puts>
     ce4:	b59d                	j	b4a <perf_monitor_end+0xd0>
	...

0000000000000cf0 <Proc_6>:
     cf0:	4789                	li	a5,2
     cf2:	02f50b63          	beq	a0,a5,d28 <Proc_6+0x38>
     cf6:	470d                	li	a4,3
     cf8:	c198                	sw	a4,0(a1)
     cfa:	4285                	li	t0,1
     cfc:	00550a63          	beq	a0,t0,d10 <Proc_6+0x20>
     d00:	02a2f063          	bgeu	t0,a0,d20 <Proc_6+0x30>
     d04:	4691                	li	a3,4
     d06:	02d51563          	bne	a0,a3,d30 <Proc_6+0x40>
     d0a:	c19c                	sw	a5,0(a1)
     d0c:	8082                	ret
     d0e:	0001                	nop
     d10:	00041337          	lui	t1,0x41
     d14:	0f832383          	lw	t2,248(t1) # 410f8 <Int_Glob>
     d18:	06400613          	li	a2,100
     d1c:	fe7658e3          	bge	a2,t2,d0c <Proc_6+0x1c>
     d20:	0005a023          	sw	zero,0(a1)
     d24:	8082                	ret
     d26:	0001                	nop
     d28:	4805                	li	a6,1
     d2a:	0105a023          	sw	a6,0(a1)
     d2e:	8082                	ret
     d30:	8082                	ret
     d32:	0001                	nop
     d34:	00000013          	nop
     d38:	00000013          	nop
     d3c:	00000013          	nop

0000000000000d40 <Proc_7>:
     d40:	2509                	addiw	a0,a0,2
     d42:	00b502bb          	addw	t0,a0,a1
     d46:	00562023          	sw	t0,0(a2)
     d4a:	8082                	ret
     d4c:	00000013          	nop

0000000000000d50 <Proc_8>:
     d50:	0056089b          	addiw	a7,a2,5
     d54:	0c800713          	li	a4,200
     d58:	02e882b3          	mul	t0,a7,a4
     d5c:	060a                	slli	a2,a2,0x2
     d5e:	4515568b          	th.srw	a3,a0,a7,2
     d62:	0515178b          	th.addsl	a5,a0,a7,2
     d66:	00c28333          	add	t1,t0,a2
     d6a:	c3d4                	sw	a3,4(a5)
     d6c:	0717ac23          	sw	a7,120(a5)
     d70:	006583b3          	add	t2,a1,t1
     d74:	0103ae83          	lw	t4,16(t2)
     d78:	0113ac23          	sw	a7,24(t2)
     d7c:	9596                	add	a1,a1,t0
     d7e:	001e8f1b          	addiw	t5,t4,1
     d82:	e513df0b          	th.swd	t5,a7,(t2),2,3
     d86:	4515450b          	th.lrw	a0,a0,a7,2
     d8a:	00c586b3          	add	a3,a1,a2
     d8e:	7ff68813          	addi	a6,a3,2047
     d92:	4e15                	li	t3,5
     d94:	00041fb7          	lui	t6,0x41
     d98:	7aa82aa3          	sw	a0,1973(a6)
     d9c:	0fcfac23          	sw	t3,248(t6) # 410f8 <Int_Glob>
     da0:	8082                	ret
     da2:	0001                	nop
     da4:	00000013          	nop
     da8:	00000013          	nop
     dac:	00000013          	nop

0000000000000db0 <Func_1>:
     db0:	0ff57513          	zext.b	a0,a0
     db4:	0ff5f593          	zext.b	a1,a1
     db8:	00b50463          	beq	a0,a1,dc0 <Func_1+0x10>
     dbc:	4501                	li	a0,0
     dbe:	8082                	ret
     dc0:	000417b7          	lui	a5,0x41
     dc4:	02a78023          	sb	a0,32(a5) # 41020 <Ch_1_Glob>
     dc8:	4505                	li	a0,1
     dca:	8082                	ret
     dcc:	00000013          	nop

0000000000000dd0 <Func_2>:
     dd0:	00254703          	lbu	a4,2(a0)
     dd4:	0035c783          	lbu	a5,3(a1)
     dd8:	02f70363          	beq	a4,a5,dfe <Func_2+0x2e>
     ddc:	1141                	addi	sp,sp,-16
     dde:	e406                	sd	ra,8(sp)
     de0:	581080ef          	jal	9b60 <strcmp>
     de4:	4381                	li	t2,0
     de6:	00a05863          	blez	a0,df6 <Func_2+0x26>
     dea:	000412b7          	lui	t0,0x41
     dee:	4329                	li	t1,10
     df0:	0e62ac23          	sw	t1,248(t0) # 410f8 <Int_Glob>
     df4:	4385                	li	t2,1
     df6:	60a2                	ld	ra,8(sp)
     df8:	851e                	mv	a0,t2
     dfa:	0141                	addi	sp,sp,16
     dfc:	8082                	ret
     dfe:	a001                	j	dfe <Func_2+0x2e>

0000000000000e00 <Func_3>:
     e00:	1579                	addi	a0,a0,-2
     e02:	00153513          	seqz	a0,a0
     e06:	8082                	ret
	...

0000000000000e10 <fputc>:
     e10:	020007b7          	lui	a5,0x2000
     e14:	fea7a823          	sw	a0,-16(a5) # 1fffff0 <__kernel_stack+0x1f11ff0>
     e18:	8082                	ret
     e1a:	00000013          	nop
     e1e:	0001                	nop

0000000000000e20 <os_critical_enter>:
     e20:	8082                	ret
     e22:	0001                	nop
     e24:	00000013          	nop
     e28:	00000013          	nop
     e2c:	00000013          	nop

0000000000000e30 <os_critical_exit>:
     e30:	8082                	ret
	...

0000000000000e40 <_out_buffer>:
     e40:	00d67463          	bgeu	a2,a3,e48 <_out_buffer+0x8>
     e44:	00c5d50b          	th.srb	a0,a1,a2,0
     e48:	8082                	ret
     e4a:	00000013          	nop
     e4e:	0001                	nop

0000000000000e50 <_out_null>:
     e50:	8082                	ret
     e52:	0001                	nop
     e54:	00000013          	nop
     e58:	00000013          	nop
     e5c:	00000013          	nop

0000000000000e60 <_out_fct>:
     e60:	c501                	beqz	a0,e68 <_out_fct+0x8>
     e62:	619c                	ld	a5,0(a1)
     e64:	658c                	ld	a1,8(a1)
     e66:	8782                	jr	a5
     e68:	8082                	ret
     e6a:	00000013          	nop
     e6e:	0001                	nop

0000000000000e70 <_out_char>:
     e70:	e111                	bnez	a0,e74 <_out_char+0x4>
     e72:	8082                	ret
     e74:	55fd                	li	a1,-1
     e76:	bf69                	j	e10 <fputc>
     e78:	00000013          	nop
     e7c:	00000013          	nop

0000000000000e80 <_ftoa>:
     e80:	7135                	addi	sp,sp,-160
     e82:	f4d6                	sd	s5,104(sp)
     e84:	f8d2                	sd	s4,112(sp)
     e86:	8abe                	mv	s5,a5
     e88:	a2a527d3          	feq.d	a5,fa0,fa0
     e8c:	fcce                	sd	s3,120(sp)
     e8e:	e14a                	sd	s2,128(sp)
     e90:	e526                	sd	s1,136(sp)
     e92:	e922                	sd	s0,144(sp)
     e94:	e4e6                	sd	s9,72(sp)
     e96:	e8e2                	sd	s8,80(sp)
     e98:	ecde                	sd	s7,88(sp)
     e9a:	f0da                	sd	s6,96(sp)
     e9c:	ed06                	sd	ra,152(sp)
     e9e:	842a                	mv	s0,a0
     ea0:	84ae                	mv	s1,a1
     ea2:	89b2                	mv	s3,a2
     ea4:	8936                	mv	s2,a3
     ea6:	8a42                	mv	s4,a6
     ea8:	4e078c63          	beqz	a5,13a0 <_ftoa+0x520>
     eac:	62a9                	lui	t0,0xa
     eae:	6f02b787          	fld	fa5,1776(t0) # a6f0 <pow10.0+0x50>
     eb2:	a2f51353          	flt.d	t1,fa0,fa5
     eb6:	520315e3          	bnez	t1,1be0 <_ftoa+0xd60>
     eba:	63a9                	lui	t2,0xa
     ebc:	6f83b007          	fld	ft0,1784(t2) # a6f8 <pow10.0+0x58>
     ec0:	a2a01553          	flt.d	a0,ft0,fa0
     ec4:	1a051a63          	bnez	a0,1078 <_ftoa+0x1f8>
     ec8:	65a9                	lui	a1,0xa
     eca:	7005b087          	fld	ft1,1792(a1) # a700 <pow10.0+0x60>
     ece:	e0ea                	sd	s10,64(sp)
     ed0:	a2a09653          	flt.d	a2,ft1,fa0
     ed4:	c219                	beqz	a2,eda <_ftoa+0x5a>
     ed6:	2220106f          	j	20f8 <_ftoa+0x1278>
     eda:	66a9                	lui	a3,0xa
     edc:	7086b107          	fld	ft2,1800(a3) # a708 <pow10.0+0x68>
     ee0:	a2251853          	flt.d	a6,fa0,ft2
     ee4:	00080463          	beqz	a6,eec <_ftoa+0x6c>
     ee8:	0e50106f          	j	27cc <_ftoa+0x194c>
     eec:	f20001d3          	fmv.d.x	ft3,zero
     ef0:	a23518d3          	flt.d	a7,fa0,ft3
     ef4:	4801                	li	a6,0
     ef6:	4c089fe3          	bnez	a7,1bd4 <_ftoa+0xd54>
     efa:	400a7b13          	andi	s6,s4,1024
     efe:	4b99                	li	s7,6
     f00:	416b970b          	th.mveqz	a4,s7,s6
     f04:	4e81                	li	t4,0
     f06:	fe070c9b          	addiw	s9,a4,-32
     f0a:	4f81                	li	t6,0
     f0c:	01010c13          	addi	s8,sp,16
     f10:	4d25                	li	s10,9
     f12:	03000e13          	li	t3,48
     f16:	060e8063          	beqz	t4,f76 <_ftoa+0xf6>
     f1a:	017e8863          	beq	t4,s7,f2a <_ftoa+0xaa>
     f1e:	0ced7763          	bgeu	s10,a4,fec <_ftoa+0x16c>
     f22:	01cc0023          	sb	t3,0(s8)
     f26:	377d                	addiw	a4,a4,-1
     f28:	4f85                	li	t6,1
     f2a:	0ced7163          	bgeu	s10,a4,fec <_ftoa+0x16c>
     f2e:	01fc5e0b          	th.srb	t3,s8,t6,0
     f32:	377d                	addiw	a4,a4,-1
     f34:	0f85                	addi	t6,t6,1
     f36:	0aed7b63          	bgeu	s10,a4,fec <_ftoa+0x16c>
     f3a:	01fc5e0b          	th.srb	t3,s8,t6,0
     f3e:	377d                	addiw	a4,a4,-1
     f40:	0f85                	addi	t6,t6,1
     f42:	0aed7563          	bgeu	s10,a4,fec <_ftoa+0x16c>
     f46:	01fc5e0b          	th.srb	t3,s8,t6,0
     f4a:	377d                	addiw	a4,a4,-1
     f4c:	0f85                	addi	t6,t6,1
     f4e:	08ed7f63          	bgeu	s10,a4,fec <_ftoa+0x16c>
     f52:	01fc5e0b          	th.srb	t3,s8,t6,0
     f56:	377d                	addiw	a4,a4,-1
     f58:	0f85                	addi	t6,t6,1
     f5a:	08ed7963          	bgeu	s10,a4,fec <_ftoa+0x16c>
     f5e:	01fc5e0b          	th.srb	t3,s8,t6,0
     f62:	377d                	addiw	a4,a4,-1
     f64:	0f85                	addi	t6,t6,1
     f66:	08ed7363          	bgeu	s10,a4,fec <_ftoa+0x16c>
     f6a:	01fc5e0b          	th.srb	t3,s8,t6,0
     f6e:	377d                	addiw	a4,a4,-1
     f70:	0f85                	addi	t6,t6,1
     f72:	06ec8b63          	beq	s9,a4,fe8 <_ftoa+0x168>
     f76:	06ed7b63          	bgeu	s10,a4,fec <_ftoa+0x16c>
     f7a:	01fc5e0b          	th.srb	t3,s8,t6,0
     f7e:	377d                	addiw	a4,a4,-1
     f80:	0f85                	addi	t6,t6,1
     f82:	8f7e                	mv	t5,t6
     f84:	06ed7463          	bgeu	s10,a4,fec <_ftoa+0x16c>
     f88:	01fc5e0b          	th.srb	t3,s8,t6,0
     f8c:	377d                	addiw	a4,a4,-1
     f8e:	0f85                	addi	t6,t6,1
     f90:	04ed7e63          	bgeu	s10,a4,fec <_ftoa+0x16c>
     f94:	01fc5e0b          	th.srb	t3,s8,t6,0
     f98:	377d                	addiw	a4,a4,-1
     f9a:	002f0f93          	addi	t6,t5,2
     f9e:	04ed7763          	bgeu	s10,a4,fec <_ftoa+0x16c>
     fa2:	01fc5e0b          	th.srb	t3,s8,t6,0
     fa6:	377d                	addiw	a4,a4,-1
     fa8:	003f0f93          	addi	t6,t5,3
     fac:	04ed7063          	bgeu	s10,a4,fec <_ftoa+0x16c>
     fb0:	01fc5e0b          	th.srb	t3,s8,t6,0
     fb4:	377d                	addiw	a4,a4,-1
     fb6:	004f0f93          	addi	t6,t5,4
     fba:	02ed7963          	bgeu	s10,a4,fec <_ftoa+0x16c>
     fbe:	01fc5e0b          	th.srb	t3,s8,t6,0
     fc2:	377d                	addiw	a4,a4,-1
     fc4:	005f0f93          	addi	t6,t5,5
     fc8:	02ed7263          	bgeu	s10,a4,fec <_ftoa+0x16c>
     fcc:	01fc5e0b          	th.srb	t3,s8,t6,0
     fd0:	377d                	addiw	a4,a4,-1
     fd2:	006f0f93          	addi	t6,t5,6
     fd6:	00ed7b63          	bgeu	s10,a4,fec <_ftoa+0x16c>
     fda:	01fc5e0b          	th.srb	t3,s8,t6,0
     fde:	377d                	addiw	a4,a4,-1
     fe0:	007f0f93          	addi	t6,t5,7
     fe4:	f8ec99e3          	bne	s9,a4,f76 <_ftoa+0xf6>
     fe8:	02000f93          	li	t6,32
     fec:	c20517d3          	fcvt.w.d	a5,fa0,rtz
     ff0:	62a9                	lui	t0,0xa
     ff2:	d2078253          	fcvt.d.w	ft4,a5
     ff6:	6a028313          	addi	t1,t0,1696 # a6a0 <pow10.0>
     ffa:	76e3668b          	th.flurd	fa3,t1,a4,3
     ffe:	0a4572d3          	fsub.d	ft5,fa0,ft4
    1002:	63a9                	lui	t2,0xa
    1004:	7383b587          	fld	fa1,1848(t2) # a738 <pow10.0+0x98>
    1008:	12d2f353          	fmul.d	ft6,ft5,fa3
    100c:	0007859b          	sext.w	a1,a5
    1010:	c23316d3          	fcvt.lu.d	a3,ft6,rtz
    1014:	d236f753          	fcvt.d.lu	fa4,a3
    1018:	0ae373d3          	fsub.d	ft7,ft6,fa4
    101c:	a2759553          	flt.d	a0,fa1,ft7
    1020:	62050663          	beqz	a0,164c <_ftoa+0x7cc>
    1024:	0685                	addi	a3,a3,1
    1026:	d236f653          	fcvt.d.lu	fa2,a3
    102a:	a2c68b53          	fle.d	s6,fa3,fa2
    102e:	000b0563          	beqz	s6,1038 <_ftoa+0x1b8>
    1032:	0017859b          	addiw	a1,a5,1
    1036:	4681                	li	a3,0
    1038:	62070463          	beqz	a4,1660 <_ftoa+0x7e0>
    103c:	fe070b9b          	addiw	s7,a4,-32
    1040:	01fc0633          	add	a2,s8,t6
    1044:	01fb8d3b          	addw	s10,s7,t6
    1048:	4ca9                	li	s9,10
    104a:	4e25                	li	t3,9
    104c:	00000013          	nop
    1050:	00ed1463          	bne	s10,a4,1058 <_ftoa+0x1d8>
    1054:	09c0106f          	j	20f0 <_ftoa+0x1270>
    1058:	0396ff33          	remu	t5,a3,s9
    105c:	82b2                	mv	t0,a2
    105e:	377d                	addiw	a4,a4,-1
    1060:	8eba                	mv	t4,a4
    1062:	030f0f9b          	addiw	t6,t5,48
    1066:	1812df8b          	th.sbia	t6,(t0),1,0
    106a:	0396d7b3          	divu	a5,a3,s9
    106e:	78de77e3          	bgeu	t3,a3,1ffc <_ftoa+0x117c>
    1072:	8616                	mv	a2,t0
    1074:	86be                	mv	a3,a5
    1076:	bfe9                	j	1050 <_ftoa+0x1d0>
    1078:	00487b13          	andi	s6,a6,4
    107c:	340b16e3          	bnez	s6,1bc8 <_ftoa+0xd48>
    1080:	68a9                	lui	a7,0xa
    1082:	4d888b93          	addi	s7,a7,1240 # a4d8 <__errno+0x22c>
    1086:	4c0d                	li	s8,3
    1088:	003a7393          	andi	t2,s4,3
    108c:	8b4e                	mv	s6,s3
    108e:	14039d63          	bnez	t2,11e8 <_ftoa+0x368>
    1092:	7c0abc8b          	th.extu	s9,s5,31,0
    1096:	159c7963          	bgeu	s8,s9,11e8 <_ftoa+0x368>
    109a:	fc6e                	sd	s11,56(sp)
    109c:	e0ea                	sd	s10,64(sp)
    109e:	413c0d33          	sub	s10,s8,s3
    10a2:	fffd4713          	not	a4,s10
    10a6:	01970e33          	add	t3,a4,s9
    10aa:	413e0f33          	sub	t5,t3,s3
    10ae:	86ca                	mv	a3,s2
    10b0:	864e                	mv	a2,s3
    10b2:	85a6                	mv	a1,s1
    10b4:	02000513          	li	a0,32
    10b8:	00198b13          	addi	s6,s3,1
    10bc:	007f7d93          	andi	s11,t5,7
    10c0:	9402                	jalr	s0
    10c2:	016d0333          	add	t1,s10,s6
    10c6:	11937b63          	bgeu	t1,s9,11dc <_ftoa+0x35c>
    10ca:	080d8963          	beqz	s11,115c <_ftoa+0x2dc>
    10ce:	4805                	li	a6,1
    10d0:	070d8b63          	beq	s11,a6,1146 <_ftoa+0x2c6>
    10d4:	4509                	li	a0,2
    10d6:	06ad8163          	beq	s11,a0,1138 <_ftoa+0x2b8>
    10da:	428d                	li	t0,3
    10dc:	045d8763          	beq	s11,t0,112a <_ftoa+0x2aa>
    10e0:	4791                	li	a5,4
    10e2:	02fd8d63          	beq	s11,a5,111c <_ftoa+0x29c>
    10e6:	4595                	li	a1,5
    10e8:	02bd8363          	beq	s11,a1,110e <_ftoa+0x28e>
    10ec:	4e99                	li	t4,6
    10ee:	01dd8963          	beq	s11,t4,1100 <_ftoa+0x280>
    10f2:	865a                	mv	a2,s6
    10f4:	86ca                	mv	a3,s2
    10f6:	85a6                	mv	a1,s1
    10f8:	02000513          	li	a0,32
    10fc:	0b05                	addi	s6,s6,1
    10fe:	9402                	jalr	s0
    1100:	865a                	mv	a2,s6
    1102:	86ca                	mv	a3,s2
    1104:	85a6                	mv	a1,s1
    1106:	02000513          	li	a0,32
    110a:	0b05                	addi	s6,s6,1
    110c:	9402                	jalr	s0
    110e:	865a                	mv	a2,s6
    1110:	86ca                	mv	a3,s2
    1112:	85a6                	mv	a1,s1
    1114:	02000513          	li	a0,32
    1118:	0b05                	addi	s6,s6,1
    111a:	9402                	jalr	s0
    111c:	865a                	mv	a2,s6
    111e:	86ca                	mv	a3,s2
    1120:	85a6                	mv	a1,s1
    1122:	02000513          	li	a0,32
    1126:	0b05                	addi	s6,s6,1
    1128:	9402                	jalr	s0
    112a:	865a                	mv	a2,s6
    112c:	86ca                	mv	a3,s2
    112e:	85a6                	mv	a1,s1
    1130:	02000513          	li	a0,32
    1134:	0b05                	addi	s6,s6,1
    1136:	9402                	jalr	s0
    1138:	865a                	mv	a2,s6
    113a:	86ca                	mv	a3,s2
    113c:	85a6                	mv	a1,s1
    113e:	02000513          	li	a0,32
    1142:	0b05                	addi	s6,s6,1
    1144:	9402                	jalr	s0
    1146:	865a                	mv	a2,s6
    1148:	86ca                	mv	a3,s2
    114a:	85a6                	mv	a1,s1
    114c:	02000513          	li	a0,32
    1150:	0b05                	addi	s6,s6,1
    1152:	9402                	jalr	s0
    1154:	016d0633          	add	a2,s10,s6
    1158:	09967263          	bgeu	a2,s9,11dc <_ftoa+0x35c>
    115c:	865a                	mv	a2,s6
    115e:	86ca                	mv	a3,s2
    1160:	85a6                	mv	a1,s1
    1162:	02000513          	li	a0,32
    1166:	9402                	jalr	s0
    1168:	001b0d93          	addi	s11,s6,1
    116c:	866e                	mv	a2,s11
    116e:	86ca                	mv	a3,s2
    1170:	85a6                	mv	a1,s1
    1172:	02000513          	li	a0,32
    1176:	9402                	jalr	s0
    1178:	002b0613          	addi	a2,s6,2
    117c:	86ca                	mv	a3,s2
    117e:	85a6                	mv	a1,s1
    1180:	02000513          	li	a0,32
    1184:	9402                	jalr	s0
    1186:	003b0d93          	addi	s11,s6,3
    118a:	866e                	mv	a2,s11
    118c:	86ca                	mv	a3,s2
    118e:	85a6                	mv	a1,s1
    1190:	02000513          	li	a0,32
    1194:	9402                	jalr	s0
    1196:	004b0613          	addi	a2,s6,4
    119a:	86ca                	mv	a3,s2
    119c:	85a6                	mv	a1,s1
    119e:	02000513          	li	a0,32
    11a2:	9402                	jalr	s0
    11a4:	005b0d93          	addi	s11,s6,5
    11a8:	866e                	mv	a2,s11
    11aa:	86ca                	mv	a3,s2
    11ac:	85a6                	mv	a1,s1
    11ae:	02000513          	li	a0,32
    11b2:	9402                	jalr	s0
    11b4:	006b0613          	addi	a2,s6,6
    11b8:	86ca                	mv	a3,s2
    11ba:	85a6                	mv	a1,s1
    11bc:	02000513          	li	a0,32
    11c0:	9402                	jalr	s0
    11c2:	007b0d93          	addi	s11,s6,7
    11c6:	866e                	mv	a2,s11
    11c8:	86ca                	mv	a3,s2
    11ca:	85a6                	mv	a1,s1
    11cc:	02000513          	li	a0,32
    11d0:	0b21                	addi	s6,s6,8
    11d2:	9402                	jalr	s0
    11d4:	016d0633          	add	a2,s10,s6
    11d8:	f99662e3          	bltu	a2,s9,115c <_ftoa+0x2dc>
    11dc:	7de2                	ld	s11,56(sp)
    11de:	6d06                	ld	s10,64(sp)
    11e0:	019986b3          	add	a3,s3,s9
    11e4:	41868b33          	sub	s6,a3,s8
    11e8:	018b8cb3          	add	s9,s7,s8
    11ec:	fffcc503          	lbu	a0,-1(s9)
    11f0:	86ca                	mv	a3,s2
    11f2:	865a                	mv	a2,s6
    11f4:	85a6                	mv	a1,s1
    11f6:	9402                	jalr	s0
    11f8:	ffecc503          	lbu	a0,-2(s9)
    11fc:	86ca                	mv	a3,s2
    11fe:	001b0613          	addi	a2,s6,1
    1202:	85a6                	mv	a1,s1
    1204:	9402                	jalr	s0
    1206:	ffdc0c93          	addi	s9,s8,-3
    120a:	819bc50b          	th.lrbu	a0,s7,s9,0
    120e:	86ca                	mv	a3,s2
    1210:	002b0613          	addi	a2,s6,2
    1214:	85a6                	mv	a1,s1
    1216:	9402                	jalr	s0
    1218:	000c8963          	beqz	s9,122a <_ftoa+0x3aa>
    121c:	000bc503          	lbu	a0,0(s7)
    1220:	86ca                	mv	a3,s2
    1222:	003b0613          	addi	a2,s6,3
    1226:	85a6                	mv	a1,s1
    1228:	9402                	jalr	s0
    122a:	002a7a13          	andi	s4,s4,2
    122e:	9b62                	add	s6,s6,s8
    1230:	140a0963          	beqz	s4,1382 <_ftoa+0x502>
    1234:	413b09b3          	sub	s3,s6,s3
    1238:	7c0aba8b          	th.extu	s5,s5,31,0
    123c:	1559f363          	bgeu	s3,s5,1382 <_ftoa+0x502>
    1240:	fff9c893          	not	a7,s3
    1244:	01588bb3          	add	s7,a7,s5
    1248:	865a                	mv	a2,s6
    124a:	86ca                	mv	a3,s2
    124c:	85a6                	mv	a1,s1
    124e:	02000513          	li	a0,32
    1252:	00198c93          	addi	s9,s3,1
    1256:	007bfc13          	andi	s8,s7,7
    125a:	0b05                	addi	s6,s6,1
    125c:	9402                	jalr	s0
    125e:	135cf263          	bgeu	s9,s5,1382 <_ftoa+0x502>
    1262:	080c0e63          	beqz	s8,12fe <_ftoa+0x47e>
    1266:	4f85                	li	t6,1
    1268:	09fc0163          	beq	s8,t6,12ea <_ftoa+0x46a>
    126c:	4389                	li	t2,2
    126e:	067c0663          	beq	s8,t2,12da <_ftoa+0x45a>
    1272:	470d                	li	a4,3
    1274:	04ec0b63          	beq	s8,a4,12ca <_ftoa+0x44a>
    1278:	4e11                	li	t3,4
    127a:	05cc0063          	beq	s8,t3,12ba <_ftoa+0x43a>
    127e:	4f15                	li	t5,5
    1280:	03ec0563          	beq	s8,t5,12aa <_ftoa+0x42a>
    1284:	4319                	li	t1,6
    1286:	006c0a63          	beq	s8,t1,129a <_ftoa+0x41a>
    128a:	865a                	mv	a2,s6
    128c:	86ca                	mv	a3,s2
    128e:	85a6                	mv	a1,s1
    1290:	02000513          	li	a0,32
    1294:	0b05                	addi	s6,s6,1
    1296:	9402                	jalr	s0
    1298:	0c85                	addi	s9,s9,1
    129a:	865a                	mv	a2,s6
    129c:	86ca                	mv	a3,s2
    129e:	85a6                	mv	a1,s1
    12a0:	02000513          	li	a0,32
    12a4:	0b05                	addi	s6,s6,1
    12a6:	9402                	jalr	s0
    12a8:	0c85                	addi	s9,s9,1
    12aa:	865a                	mv	a2,s6
    12ac:	86ca                	mv	a3,s2
    12ae:	85a6                	mv	a1,s1
    12b0:	02000513          	li	a0,32
    12b4:	0b05                	addi	s6,s6,1
    12b6:	9402                	jalr	s0
    12b8:	0c85                	addi	s9,s9,1
    12ba:	865a                	mv	a2,s6
    12bc:	86ca                	mv	a3,s2
    12be:	85a6                	mv	a1,s1
    12c0:	02000513          	li	a0,32
    12c4:	0b05                	addi	s6,s6,1
    12c6:	9402                	jalr	s0
    12c8:	0c85                	addi	s9,s9,1
    12ca:	865a                	mv	a2,s6
    12cc:	86ca                	mv	a3,s2
    12ce:	85a6                	mv	a1,s1
    12d0:	02000513          	li	a0,32
    12d4:	0b05                	addi	s6,s6,1
    12d6:	9402                	jalr	s0
    12d8:	0c85                	addi	s9,s9,1
    12da:	865a                	mv	a2,s6
    12dc:	86ca                	mv	a3,s2
    12de:	85a6                	mv	a1,s1
    12e0:	02000513          	li	a0,32
    12e4:	0b05                	addi	s6,s6,1
    12e6:	9402                	jalr	s0
    12e8:	0c85                	addi	s9,s9,1
    12ea:	865a                	mv	a2,s6
    12ec:	86ca                	mv	a3,s2
    12ee:	85a6                	mv	a1,s1
    12f0:	02000513          	li	a0,32
    12f4:	0c85                	addi	s9,s9,1
    12f6:	0b05                	addi	s6,s6,1
    12f8:	9402                	jalr	s0
    12fa:	095cf463          	bgeu	s9,s5,1382 <_ftoa+0x502>
    12fe:	865a                	mv	a2,s6
    1300:	86ca                	mv	a3,s2
    1302:	85a6                	mv	a1,s1
    1304:	02000513          	li	a0,32
    1308:	9402                	jalr	s0
    130a:	001b0a13          	addi	s4,s6,1
    130e:	8652                	mv	a2,s4
    1310:	86ca                	mv	a3,s2
    1312:	85a6                	mv	a1,s1
    1314:	02000513          	li	a0,32
    1318:	9402                	jalr	s0
    131a:	002b0993          	addi	s3,s6,2
    131e:	864e                	mv	a2,s3
    1320:	86ca                	mv	a3,s2
    1322:	85a6                	mv	a1,s1
    1324:	02000513          	li	a0,32
    1328:	9402                	jalr	s0
    132a:	003b0c13          	addi	s8,s6,3
    132e:	8662                	mv	a2,s8
    1330:	86ca                	mv	a3,s2
    1332:	85a6                	mv	a1,s1
    1334:	02000513          	li	a0,32
    1338:	9402                	jalr	s0
    133a:	004b0b93          	addi	s7,s6,4
    133e:	86ca                	mv	a3,s2
    1340:	865e                	mv	a2,s7
    1342:	85a6                	mv	a1,s1
    1344:	02000513          	li	a0,32
    1348:	9402                	jalr	s0
    134a:	005b0a13          	addi	s4,s6,5
    134e:	86ca                	mv	a3,s2
    1350:	8652                	mv	a2,s4
    1352:	85a6                	mv	a1,s1
    1354:	02000513          	li	a0,32
    1358:	9402                	jalr	s0
    135a:	006b0993          	addi	s3,s6,6
    135e:	86ca                	mv	a3,s2
    1360:	864e                	mv	a2,s3
    1362:	85a6                	mv	a1,s1
    1364:	02000513          	li	a0,32
    1368:	9402                	jalr	s0
    136a:	007b0c13          	addi	s8,s6,7
    136e:	86ca                	mv	a3,s2
    1370:	8662                	mv	a2,s8
    1372:	85a6                	mv	a1,s1
    1374:	02000513          	li	a0,32
    1378:	0ca1                	addi	s9,s9,8
    137a:	0b21                	addi	s6,s6,8
    137c:	9402                	jalr	s0
    137e:	f95ce0e3          	bltu	s9,s5,12fe <_ftoa+0x47e>
    1382:	64aa                	ld	s1,136(sp)
    1384:	644a                	ld	s0,144(sp)
    1386:	60ea                	ld	ra,152(sp)
    1388:	6ca6                	ld	s9,72(sp)
    138a:	6c46                	ld	s8,80(sp)
    138c:	7aa6                	ld	s5,104(sp)
    138e:	7a46                	ld	s4,112(sp)
    1390:	79e6                	ld	s3,120(sp)
    1392:	690a                	ld	s2,128(sp)
    1394:	855a                	mv	a0,s6
    1396:	6be6                	ld	s7,88(sp)
    1398:	7b06                	ld	s6,96(sp)
    139a:	610d                	addi	sp,sp,160
    139c:	8082                	ret
    139e:	0001                	nop
    13a0:	00387893          	andi	a7,a6,3
    13a4:	8cb2                	mv	s9,a2
    13a6:	12089563          	bnez	a7,14d0 <_ftoa+0x650>
    13aa:	438d                	li	t2,3
    13ac:	7c0abf8b          	th.extu	t6,s5,31,0
    13b0:	1353f063          	bgeu	t2,s5,14d0 <_ftoa+0x650>
    13b4:	ffd60713          	addi	a4,a2,-3
    13b8:	01f70cb3          	add	s9,a4,t6
    13bc:	40cc8e33          	sub	t3,s9,a2
    13c0:	007e7f13          	andi	t5,t3,7
    13c4:	8b32                	mv	s6,a2
    13c6:	080f0463          	beqz	t5,144e <_ftoa+0x5ce>
    13ca:	4305                	li	t1,1
    13cc:	066f0863          	beq	t5,t1,143c <_ftoa+0x5bc>
    13d0:	4809                	li	a6,2
    13d2:	050f0e63          	beq	t5,a6,142e <_ftoa+0x5ae>
    13d6:	047f0563          	beq	t5,t2,1420 <_ftoa+0x5a0>
    13da:	4511                	li	a0,4
    13dc:	02af0b63          	beq	t5,a0,1412 <_ftoa+0x592>
    13e0:	4295                	li	t0,5
    13e2:	025f0163          	beq	t5,t0,1404 <_ftoa+0x584>
    13e6:	4799                	li	a5,6
    13e8:	00ff0763          	beq	t5,a5,13f6 <_ftoa+0x576>
    13ec:	02000513          	li	a0,32
    13f0:	00160b13          	addi	s6,a2,1
    13f4:	9402                	jalr	s0
    13f6:	865a                	mv	a2,s6
    13f8:	86ca                	mv	a3,s2
    13fa:	85a6                	mv	a1,s1
    13fc:	02000513          	li	a0,32
    1400:	0b05                	addi	s6,s6,1
    1402:	9402                	jalr	s0
    1404:	865a                	mv	a2,s6
    1406:	86ca                	mv	a3,s2
    1408:	85a6                	mv	a1,s1
    140a:	02000513          	li	a0,32
    140e:	0b05                	addi	s6,s6,1
    1410:	9402                	jalr	s0
    1412:	865a                	mv	a2,s6
    1414:	86ca                	mv	a3,s2
    1416:	85a6                	mv	a1,s1
    1418:	02000513          	li	a0,32
    141c:	0b05                	addi	s6,s6,1
    141e:	9402                	jalr	s0
    1420:	865a                	mv	a2,s6
    1422:	86ca                	mv	a3,s2
    1424:	85a6                	mv	a1,s1
    1426:	02000513          	li	a0,32
    142a:	0b05                	addi	s6,s6,1
    142c:	9402                	jalr	s0
    142e:	865a                	mv	a2,s6
    1430:	86ca                	mv	a3,s2
    1432:	85a6                	mv	a1,s1
    1434:	02000513          	li	a0,32
    1438:	0b05                	addi	s6,s6,1
    143a:	9402                	jalr	s0
    143c:	865a                	mv	a2,s6
    143e:	86ca                	mv	a3,s2
    1440:	0b05                	addi	s6,s6,1
    1442:	85a6                	mv	a1,s1
    1444:	02000513          	li	a0,32
    1448:	9402                	jalr	s0
    144a:	099b0363          	beq	s6,s9,14d0 <_ftoa+0x650>
    144e:	865a                	mv	a2,s6
    1450:	86ca                	mv	a3,s2
    1452:	85a6                	mv	a1,s1
    1454:	02000513          	li	a0,32
    1458:	9402                	jalr	s0
    145a:	001b0b93          	addi	s7,s6,1
    145e:	865e                	mv	a2,s7
    1460:	86ca                	mv	a3,s2
    1462:	85a6                	mv	a1,s1
    1464:	02000513          	li	a0,32
    1468:	9402                	jalr	s0
    146a:	002b0c13          	addi	s8,s6,2
    146e:	8662                	mv	a2,s8
    1470:	86ca                	mv	a3,s2
    1472:	85a6                	mv	a1,s1
    1474:	02000513          	li	a0,32
    1478:	9402                	jalr	s0
    147a:	003b0b93          	addi	s7,s6,3
    147e:	865e                	mv	a2,s7
    1480:	86ca                	mv	a3,s2
    1482:	85a6                	mv	a1,s1
    1484:	02000513          	li	a0,32
    1488:	9402                	jalr	s0
    148a:	004b0c13          	addi	s8,s6,4
    148e:	8662                	mv	a2,s8
    1490:	86ca                	mv	a3,s2
    1492:	85a6                	mv	a1,s1
    1494:	02000513          	li	a0,32
    1498:	9402                	jalr	s0
    149a:	005b0b93          	addi	s7,s6,5
    149e:	865e                	mv	a2,s7
    14a0:	86ca                	mv	a3,s2
    14a2:	85a6                	mv	a1,s1
    14a4:	02000513          	li	a0,32
    14a8:	9402                	jalr	s0
    14aa:	006b0c13          	addi	s8,s6,6
    14ae:	86ca                	mv	a3,s2
    14b0:	8662                	mv	a2,s8
    14b2:	85a6                	mv	a1,s1
    14b4:	02000513          	li	a0,32
    14b8:	9402                	jalr	s0
    14ba:	007b0b93          	addi	s7,s6,7
    14be:	86ca                	mv	a3,s2
    14c0:	0b21                	addi	s6,s6,8
    14c2:	865e                	mv	a2,s7
    14c4:	85a6                	mv	a1,s1
    14c6:	02000513          	li	a0,32
    14ca:	9402                	jalr	s0
    14cc:	f99b11e3          	bne	s6,s9,144e <_ftoa+0x5ce>
    14d0:	4b8d                	li	s7,3
    14d2:	65a9                	lui	a1,0xa
    14d4:	9cde                	add	s9,s9,s7
    14d6:	4e058c13          	addi	s8,a1,1248 # a4e0 <__errno+0x234>
    14da:	0001                	nop
    14dc:	00000013          	nop
    14e0:	417c8633          	sub	a2,s9,s7
    14e4:	1bfd                	addi	s7,s7,-1
    14e6:	817c450b          	th.lrbu	a0,s8,s7,0
    14ea:	86ca                	mv	a3,s2
    14ec:	85a6                	mv	a1,s1
    14ee:	8b66                	mv	s6,s9
    14f0:	9402                	jalr	s0
    14f2:	fe0b97e3          	bnez	s7,14e0 <_ftoa+0x660>
    14f6:	002a7e93          	andi	t4,s4,2
    14fa:	e80e84e3          	beqz	t4,1382 <_ftoa+0x502>
    14fe:	7c0aba8b          	th.extu	s5,s5,31,0
    1502:	413c8633          	sub	a2,s9,s3
    1506:	e7567ee3          	bgeu	a2,s5,1382 <_ftoa+0x502>
    150a:	fffcc693          	not	a3,s9
    150e:	01568a33          	add	s4,a3,s5
    1512:	013a08b3          	add	a7,s4,s3
    1516:	86ca                	mv	a3,s2
    1518:	8666                	mv	a2,s9
    151a:	85a6                	mv	a1,s1
    151c:	02000513          	li	a0,32
    1520:	0078fb93          	andi	s7,a7,7
    1524:	001c8b13          	addi	s6,s9,1
    1528:	9402                	jalr	s0
    152a:	413b0fb3          	sub	t6,s6,s3
    152e:	e55ffae3          	bgeu	t6,s5,1382 <_ftoa+0x502>
    1532:	080b8963          	beqz	s7,15c4 <_ftoa+0x744>
    1536:	4385                	li	t2,1
    1538:	067b8b63          	beq	s7,t2,15ae <_ftoa+0x72e>
    153c:	4709                	li	a4,2
    153e:	06eb8163          	beq	s7,a4,15a0 <_ftoa+0x720>
    1542:	4e0d                	li	t3,3
    1544:	05cb8763          	beq	s7,t3,1592 <_ftoa+0x712>
    1548:	4f11                	li	t5,4
    154a:	03eb8d63          	beq	s7,t5,1584 <_ftoa+0x704>
    154e:	4315                	li	t1,5
    1550:	026b8363          	beq	s7,t1,1576 <_ftoa+0x6f6>
    1554:	4819                	li	a6,6
    1556:	010b8963          	beq	s7,a6,1568 <_ftoa+0x6e8>
    155a:	865a                	mv	a2,s6
    155c:	86ca                	mv	a3,s2
    155e:	85a6                	mv	a1,s1
    1560:	02000513          	li	a0,32
    1564:	0b05                	addi	s6,s6,1
    1566:	9402                	jalr	s0
    1568:	865a                	mv	a2,s6
    156a:	86ca                	mv	a3,s2
    156c:	85a6                	mv	a1,s1
    156e:	02000513          	li	a0,32
    1572:	0b05                	addi	s6,s6,1
    1574:	9402                	jalr	s0
    1576:	865a                	mv	a2,s6
    1578:	86ca                	mv	a3,s2
    157a:	85a6                	mv	a1,s1
    157c:	02000513          	li	a0,32
    1580:	0b05                	addi	s6,s6,1
    1582:	9402                	jalr	s0
    1584:	865a                	mv	a2,s6
    1586:	86ca                	mv	a3,s2
    1588:	85a6                	mv	a1,s1
    158a:	02000513          	li	a0,32
    158e:	0b05                	addi	s6,s6,1
    1590:	9402                	jalr	s0
    1592:	865a                	mv	a2,s6
    1594:	86ca                	mv	a3,s2
    1596:	85a6                	mv	a1,s1
    1598:	02000513          	li	a0,32
    159c:	0b05                	addi	s6,s6,1
    159e:	9402                	jalr	s0
    15a0:	865a                	mv	a2,s6
    15a2:	86ca                	mv	a3,s2
    15a4:	85a6                	mv	a1,s1
    15a6:	02000513          	li	a0,32
    15aa:	0b05                	addi	s6,s6,1
    15ac:	9402                	jalr	s0
    15ae:	865a                	mv	a2,s6
    15b0:	02000513          	li	a0,32
    15b4:	86ca                	mv	a3,s2
    15b6:	85a6                	mv	a1,s1
    15b8:	0b05                	addi	s6,s6,1
    15ba:	9402                	jalr	s0
    15bc:	413b0533          	sub	a0,s6,s3
    15c0:	dd5571e3          	bgeu	a0,s5,1382 <_ftoa+0x502>
    15c4:	865a                	mv	a2,s6
    15c6:	86ca                	mv	a3,s2
    15c8:	85a6                	mv	a1,s1
    15ca:	02000513          	li	a0,32
    15ce:	9402                	jalr	s0
    15d0:	001b0c93          	addi	s9,s6,1
    15d4:	8666                	mv	a2,s9
    15d6:	86ca                	mv	a3,s2
    15d8:	85a6                	mv	a1,s1
    15da:	02000513          	li	a0,32
    15de:	9402                	jalr	s0
    15e0:	002b0c13          	addi	s8,s6,2
    15e4:	8662                	mv	a2,s8
    15e6:	86ca                	mv	a3,s2
    15e8:	85a6                	mv	a1,s1
    15ea:	02000513          	li	a0,32
    15ee:	9402                	jalr	s0
    15f0:	003b0a13          	addi	s4,s6,3
    15f4:	8652                	mv	a2,s4
    15f6:	86ca                	mv	a3,s2
    15f8:	85a6                	mv	a1,s1
    15fa:	02000513          	li	a0,32
    15fe:	9402                	jalr	s0
    1600:	004b0b93          	addi	s7,s6,4
    1604:	86ca                	mv	a3,s2
    1606:	865e                	mv	a2,s7
    1608:	85a6                	mv	a1,s1
    160a:	02000513          	li	a0,32
    160e:	9402                	jalr	s0
    1610:	005b0c93          	addi	s9,s6,5
    1614:	86ca                	mv	a3,s2
    1616:	8666                	mv	a2,s9
    1618:	85a6                	mv	a1,s1
    161a:	02000513          	li	a0,32
    161e:	9402                	jalr	s0
    1620:	006b0c13          	addi	s8,s6,6
    1624:	86ca                	mv	a3,s2
    1626:	8662                	mv	a2,s8
    1628:	85a6                	mv	a1,s1
    162a:	02000513          	li	a0,32
    162e:	9402                	jalr	s0
    1630:	007b0a13          	addi	s4,s6,7
    1634:	02000513          	li	a0,32
    1638:	86ca                	mv	a3,s2
    163a:	8652                	mv	a2,s4
    163c:	85a6                	mv	a1,s1
    163e:	0b21                	addi	s6,s6,8
    1640:	9402                	jalr	s0
    1642:	413b0533          	sub	a0,s6,s3
    1646:	f7556fe3          	bltu	a0,s5,15c4 <_ftoa+0x744>
    164a:	bb25                	j	1382 <_ftoa+0x502>
    164c:	a2b39653          	flt.d	a2,ft7,fa1
    1650:	9e0614e3          	bnez	a2,1038 <_ftoa+0x1b8>
    1654:	c299                	beqz	a3,165a <_ftoa+0x7da>
    1656:	1120106f          	j	2768 <_ftoa+0x18e8>
    165a:	0685                	addi	a3,a3,1
    165c:	9e0710e3          	bnez	a4,103c <_ftoa+0x1bc>
    1660:	d2058853          	fcvt.d.w	fa6,a1
    1664:	7383b887          	fld	fa7,1848(t2)
    1668:	0b057553          	fsub.d	fa0,fa0,fa6
    166c:	0015839b          	addiw	t2,a1,1
    1670:	ffe3fb13          	andi	s6,t2,-2
    1674:	a3151e53          	flt.d	t3,fa0,fa7
    1678:	000b089b          	sext.w	a7,s6
    167c:	41c8958b          	th.mveqz	a1,a7,t3
    1680:	01fc07b3          	add	a5,s8,t6
    1684:	03010f13          	addi	t5,sp,48
    1688:	40ff0633          	sub	a2,t5,a5
    168c:	00767693          	andi	a3,a2,7
    1690:	4ea9                	li	t4,10
    1692:	c6f9                	beqz	a3,1760 <_ftoa+0x8e0>
    1694:	03d5efbb          	remw	t6,a1,t4
    1698:	873e                	mv	a4,a5
    169a:	03d5c5bb          	divw	a1,a1,t4
    169e:	030f831b          	addiw	t1,t6,48
    16a2:	1817530b          	th.sbia	t1,(a4),1,0
    16a6:	7e058963          	beqz	a1,1e98 <_ftoa+0x1018>
    16aa:	4505                	li	a0,1
    16ac:	87ba                	mv	a5,a4
    16ae:	0aa68963          	beq	a3,a0,1760 <_ftoa+0x8e0>
    16b2:	4b89                	li	s7,2
    16b4:	09768a63          	beq	a3,s7,1748 <_ftoa+0x8c8>
    16b8:	4c8d                	li	s9,3
    16ba:	07968b63          	beq	a3,s9,1730 <_ftoa+0x8b0>
    16be:	4d11                	li	s10,4
    16c0:	05a68c63          	beq	a3,s10,1718 <_ftoa+0x898>
    16c4:	4295                	li	t0,5
    16c6:	02568d63          	beq	a3,t0,1700 <_ftoa+0x880>
    16ca:	4399                	li	t2,6
    16cc:	00768e63          	beq	a3,t2,16e8 <_ftoa+0x868>
    16d0:	03d5eb3b          	remw	s6,a1,t4
    16d4:	8e3a                	mv	t3,a4
    16d6:	03d5c5bb          	divw	a1,a1,t4
    16da:	030b089b          	addiw	a7,s6,48
    16de:	181e588b          	th.sbia	a7,(t3),1,0
    16e2:	7a058b63          	beqz	a1,1e98 <_ftoa+0x1018>
    16e6:	87f2                	mv	a5,t3
    16e8:	03d5ef3b          	remw	t5,a1,t4
    16ec:	863e                	mv	a2,a5
    16ee:	03d5c5bb          	divw	a1,a1,t4
    16f2:	030f069b          	addiw	a3,t5,48
    16f6:	1816568b          	th.sbia	a3,(a2),1,0
    16fa:	78058f63          	beqz	a1,1e98 <_ftoa+0x1018>
    16fe:	87b2                	mv	a5,a2
    1700:	03d5efbb          	remw	t6,a1,t4
    1704:	873e                	mv	a4,a5
    1706:	03d5c5bb          	divw	a1,a1,t4
    170a:	030f831b          	addiw	t1,t6,48
    170e:	1817530b          	th.sbia	t1,(a4),1,0
    1712:	78058363          	beqz	a1,1e98 <_ftoa+0x1018>
    1716:	87ba                	mv	a5,a4
    1718:	03d5e53b          	remw	a0,a1,t4
    171c:	8cbe                	mv	s9,a5
    171e:	03d5c5bb          	divw	a1,a1,t4
    1722:	03050b9b          	addiw	s7,a0,48
    1726:	181cdb8b          	th.sbia	s7,(s9),1,0
    172a:	76058763          	beqz	a1,1e98 <_ftoa+0x1018>
    172e:	87e6                	mv	a5,s9
    1730:	03d5ed3b          	remw	s10,a1,t4
    1734:	83be                	mv	t2,a5
    1736:	03d5c5bb          	divw	a1,a1,t4
    173a:	030d029b          	addiw	t0,s10,48
    173e:	1813d28b          	th.sbia	t0,(t2),1,0
    1742:	74058b63          	beqz	a1,1e98 <_ftoa+0x1018>
    1746:	879e                	mv	a5,t2
    1748:	03d5eb3b          	remw	s6,a1,t4
    174c:	8e3e                	mv	t3,a5
    174e:	03d5c5bb          	divw	a1,a1,t4
    1752:	030b089b          	addiw	a7,s6,48
    1756:	181e588b          	th.sbia	a7,(t3),1,0
    175a:	72058f63          	beqz	a1,1e98 <_ftoa+0x1018>
    175e:	87f2                	mv	a5,t3
    1760:	03010f13          	addi	t5,sp,48
    1764:	0cff0463          	beq	t5,a5,182c <_ftoa+0x9ac>
    1768:	03d5e6bb          	remw	a3,a1,t4
    176c:	863e                	mv	a2,a5
    176e:	03d5c73b          	divw	a4,a1,t4
    1772:	0306831b          	addiw	t1,a3,48
    1776:	1816530b          	th.sbia	t1,(a2),1,0
    177a:	70070f63          	beqz	a4,1e98 <_ftoa+0x1018>
    177e:	03d7653b          	remw	a0,a4,t4
    1782:	87b2                	mv	a5,a2
    1784:	03d74cbb          	divw	s9,a4,t4
    1788:	03050b9b          	addiw	s7,a0,48
    178c:	01760023          	sb	s7,0(a2)
    1790:	700c8463          	beqz	s9,1e98 <_ftoa+0x1018>
    1794:	03dced3b          	remw	s10,s9,t4
    1798:	03dcc3bb          	divw	t2,s9,t4
    179c:	030d029b          	addiw	t0,s10,48
    17a0:	0817d28b          	th.sbib	t0,(a5),1,0
    17a4:	6e038a63          	beqz	t2,1e98 <_ftoa+0x1018>
    17a8:	03d3eb3b          	remw	s6,t2,t4
    17ac:	00260793          	addi	a5,a2,2
    17b0:	03d3ce3b          	divw	t3,t2,t4
    17b4:	030b089b          	addiw	a7,s6,48
    17b8:	01160123          	sb	a7,2(a2)
    17bc:	6c0e0e63          	beqz	t3,1e98 <_ftoa+0x1018>
    17c0:	03de6f3b          	remw	t5,t3,t4
    17c4:	00360793          	addi	a5,a2,3
    17c8:	03de4fbb          	divw	t6,t3,t4
    17cc:	030f059b          	addiw	a1,t5,48
    17d0:	00b601a3          	sb	a1,3(a2)
    17d4:	6c0f8263          	beqz	t6,1e98 <_ftoa+0x1018>
    17d8:	03dfe6bb          	remw	a3,t6,t4
    17dc:	00460793          	addi	a5,a2,4
    17e0:	03dfc73b          	divw	a4,t6,t4
    17e4:	0306831b          	addiw	t1,a3,48
    17e8:	00660223          	sb	t1,4(a2)
    17ec:	6a070663          	beqz	a4,1e98 <_ftoa+0x1018>
    17f0:	03d7653b          	remw	a0,a4,t4
    17f4:	00560793          	addi	a5,a2,5
    17f8:	03d74cbb          	divw	s9,a4,t4
    17fc:	03050b9b          	addiw	s7,a0,48
    1800:	017602a3          	sb	s7,5(a2)
    1804:	680c8a63          	beqz	s9,1e98 <_ftoa+0x1018>
    1808:	03dced3b          	remw	s10,s9,t4
    180c:	00660793          	addi	a5,a2,6
    1810:	03dcc5bb          	divw	a1,s9,t4
    1814:	030d029b          	addiw	t0,s10,48
    1818:	00560323          	sb	t0,6(a2)
    181c:	66058e63          	beqz	a1,1e98 <_ftoa+0x1018>
    1820:	00760793          	addi	a5,a2,7
    1824:	03010f13          	addi	t5,sp,48
    1828:	f4ff10e3          	bne	t5,a5,1768 <_ftoa+0x8e8>
    182c:	003a7593          	andi	a1,s4,3
    1830:	4785                	li	a5,1
    1832:	78f599e3          	bne	a1,a5,27c4 <_ftoa+0x1944>
    1836:	6e0a87e3          	beqz	s5,2724 <_ftoa+0x18a4>
    183a:	78080fe3          	beqz	a6,27d8 <_ftoa+0x1958>
    183e:	3afd                	addiw	s5,s5,-1
    1840:	02000b13          	li	s6,32
    1844:	7c0abf8b          	th.extu	t6,s5,31,0
    1848:	115b7363          	bgeu	s6,s5,194e <_ftoa+0xace>
    184c:	02000293          	li	t0,32
    1850:	416287b3          	sub	a5,t0,s6
    1854:	0077fe93          	andi	t4,a5,7
    1858:	016c0733          	add	a4,s8,s6
    185c:	03000593          	li	a1,48
    1860:	060e8763          	beqz	t4,18ce <_ftoa+0xa4e>
    1864:	0b05                	addi	s6,s6,1
    1866:	1817558b          	th.sbia	a1,(a4),1,0
    186a:	0dfb0763          	beq	s6,t6,1938 <_ftoa+0xab8>
    186e:	4605                	li	a2,1
    1870:	04ce8f63          	beq	t4,a2,18ce <_ftoa+0xa4e>
    1874:	4389                	li	t2,2
    1876:	047e8763          	beq	t4,t2,18c4 <_ftoa+0xa44>
    187a:	488d                	li	a7,3
    187c:	031e8f63          	beq	t4,a7,18ba <_ftoa+0xa3a>
    1880:	4e11                	li	t3,4
    1882:	03ce8763          	beq	t4,t3,18b0 <_ftoa+0xa30>
    1886:	4f15                	li	t5,5
    1888:	01ee8f63          	beq	t4,t5,18a6 <_ftoa+0xa26>
    188c:	4319                	li	t1,6
    188e:	006e8763          	beq	t4,t1,189c <_ftoa+0xa1c>
    1892:	0b05                	addi	s6,s6,1
    1894:	1817558b          	th.sbia	a1,(a4),1,0
    1898:	0bfb0063          	beq	s6,t6,1938 <_ftoa+0xab8>
    189c:	0b05                	addi	s6,s6,1
    189e:	1817558b          	th.sbia	a1,(a4),1,0
    18a2:	09fb0b63          	beq	s6,t6,1938 <_ftoa+0xab8>
    18a6:	0b05                	addi	s6,s6,1
    18a8:	1817558b          	th.sbia	a1,(a4),1,0
    18ac:	09fb0663          	beq	s6,t6,1938 <_ftoa+0xab8>
    18b0:	0b05                	addi	s6,s6,1
    18b2:	1817558b          	th.sbia	a1,(a4),1,0
    18b6:	09fb0163          	beq	s6,t6,1938 <_ftoa+0xab8>
    18ba:	0b05                	addi	s6,s6,1
    18bc:	1817558b          	th.sbia	a1,(a4),1,0
    18c0:	07fb0c63          	beq	s6,t6,1938 <_ftoa+0xab8>
    18c4:	0b05                	addi	s6,s6,1
    18c6:	1817558b          	th.sbia	a1,(a4),1,0
    18ca:	07fb0763          	beq	s6,t6,1938 <_ftoa+0xab8>
    18ce:	6e5b05e3          	beq	s6,t0,27b8 <_ftoa+0x1938>
    18d2:	0b05                	addi	s6,s6,1
    18d4:	00b70023          	sb	a1,0(a4)
    18d8:	86da                	mv	a3,s6
    18da:	05fb0f63          	beq	s6,t6,1938 <_ftoa+0xab8>
    18de:	0b05                	addi	s6,s6,1
    18e0:	00b700a3          	sb	a1,1(a4)
    18e4:	05fb0a63          	beq	s6,t6,1938 <_ftoa+0xab8>
    18e8:	00268b13          	addi	s6,a3,2
    18ec:	00b70123          	sb	a1,2(a4)
    18f0:	05fb0463          	beq	s6,t6,1938 <_ftoa+0xab8>
    18f4:	00368b13          	addi	s6,a3,3
    18f8:	00b701a3          	sb	a1,3(a4)
    18fc:	03fb0e63          	beq	s6,t6,1938 <_ftoa+0xab8>
    1900:	00468b13          	addi	s6,a3,4
    1904:	00b70223          	sb	a1,4(a4)
    1908:	03fb0863          	beq	s6,t6,1938 <_ftoa+0xab8>
    190c:	00568b13          	addi	s6,a3,5
    1910:	00b702a3          	sb	a1,5(a4)
    1914:	03fb0263          	beq	s6,t6,1938 <_ftoa+0xab8>
    1918:	00668b13          	addi	s6,a3,6
    191c:	00b70323          	sb	a1,6(a4)
    1920:	01fb0c63          	beq	s6,t6,1938 <_ftoa+0xab8>
    1924:	00b703a3          	sb	a1,7(a4)
    1928:	00768b13          	addi	s6,a3,7
    192c:	0721                	addi	a4,a4,8
    192e:	fbfb10e3          	bne	s6,t6,18ce <_ftoa+0xa4e>
    1932:	0001                	nop
    1934:	00000013          	nop
    1938:	685b00e3          	beq	s6,t0,27b8 <_ftoa+0x1938>
    193c:	6e080fe3          	beqz	a6,283a <_ftoa+0x19ba>
    1940:	002f8d33          	add	s10,t6,sp
    1944:	02d00293          	li	t0,45
    1948:	0b05                	addi	s6,s6,1
    194a:	005d0823          	sb	t0,16(s10)
    194e:	8d4e                	mv	s10,s3
    1950:	9d5a                	add	s10,s10,s6
    1952:	016c0bb3          	add	s7,s8,s6
    1956:	007b7b13          	andi	s6,s6,7
    195a:	01ac0cb3          	add	s9,s8,s10
    195e:	080b0163          	beqz	s6,19e0 <_ftoa+0xb60>
    1962:	4585                	li	a1,1
    1964:	06bb0463          	beq	s6,a1,19cc <_ftoa+0xb4c>
    1968:	4789                	li	a5,2
    196a:	04fb0a63          	beq	s6,a5,19be <_ftoa+0xb3e>
    196e:	4e8d                	li	t4,3
    1970:	05db0063          	beq	s6,t4,19b0 <_ftoa+0xb30>
    1974:	4611                	li	a2,4
    1976:	02cb0663          	beq	s6,a2,19a2 <_ftoa+0xb22>
    197a:	4395                	li	t2,5
    197c:	007b0c63          	beq	s6,t2,1994 <_ftoa+0xb14>
    1980:	4899                	li	a7,6
    1982:	5f1b1de3          	bne	s6,a7,277c <_ftoa+0x18fc>
    1986:	417c8633          	sub	a2,s9,s7
    198a:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    198e:	86ca                	mv	a3,s2
    1990:	85a6                	mv	a1,s1
    1992:	9402                	jalr	s0
    1994:	417c8633          	sub	a2,s9,s7
    1998:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    199c:	86ca                	mv	a3,s2
    199e:	85a6                	mv	a1,s1
    19a0:	9402                	jalr	s0
    19a2:	417c8633          	sub	a2,s9,s7
    19a6:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    19aa:	86ca                	mv	a3,s2
    19ac:	85a6                	mv	a1,s1
    19ae:	9402                	jalr	s0
    19b0:	417c8633          	sub	a2,s9,s7
    19b4:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    19b8:	86ca                	mv	a3,s2
    19ba:	85a6                	mv	a1,s1
    19bc:	9402                	jalr	s0
    19be:	417c8633          	sub	a2,s9,s7
    19c2:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    19c6:	86ca                	mv	a3,s2
    19c8:	85a6                	mv	a1,s1
    19ca:	9402                	jalr	s0
    19cc:	417c8633          	sub	a2,s9,s7
    19d0:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    19d4:	86ca                	mv	a3,s2
    19d6:	85a6                	mv	a1,s1
    19d8:	8b6a                	mv	s6,s10
    19da:	9402                	jalr	s0
    19dc:	097c0663          	beq	s8,s7,1a68 <_ftoa+0xbe8>
    19e0:	fc6e                	sd	s11,56(sp)
    19e2:	8dde                	mv	s11,s7
    19e4:	89fdc50b          	th.lbuib	a0,(s11),-1,0
    19e8:	417c8633          	sub	a2,s9,s7
    19ec:	86ca                	mv	a3,s2
    19ee:	85a6                	mv	a1,s1
    19f0:	9402                	jalr	s0
    19f2:	8b5e                	mv	s6,s7
    19f4:	89eb450b          	th.lbuib	a0,(s6),-2,0
    19f8:	41bc8633          	sub	a2,s9,s11
    19fc:	86ca                	mv	a3,s2
    19fe:	85a6                	mv	a1,s1
    1a00:	9402                	jalr	s0
    1a02:	8dde                	mv	s11,s7
    1a04:	89ddc50b          	th.lbuib	a0,(s11),-3,0
    1a08:	416c8633          	sub	a2,s9,s6
    1a0c:	86ca                	mv	a3,s2
    1a0e:	85a6                	mv	a1,s1
    1a10:	9402                	jalr	s0
    1a12:	8b5e                	mv	s6,s7
    1a14:	89cb450b          	th.lbuib	a0,(s6),-4,0
    1a18:	41bc8633          	sub	a2,s9,s11
    1a1c:	86ca                	mv	a3,s2
    1a1e:	85a6                	mv	a1,s1
    1a20:	9402                	jalr	s0
    1a22:	8dde                	mv	s11,s7
    1a24:	89bdc50b          	th.lbuib	a0,(s11),-5,0
    1a28:	416c8633          	sub	a2,s9,s6
    1a2c:	86ca                	mv	a3,s2
    1a2e:	85a6                	mv	a1,s1
    1a30:	9402                	jalr	s0
    1a32:	8b5e                	mv	s6,s7
    1a34:	89ab450b          	th.lbuib	a0,(s6),-6,0
    1a38:	41bc8633          	sub	a2,s9,s11
    1a3c:	86ca                	mv	a3,s2
    1a3e:	85a6                	mv	a1,s1
    1a40:	9402                	jalr	s0
    1a42:	8dde                	mv	s11,s7
    1a44:	899dc50b          	th.lbuib	a0,(s11),-7,0
    1a48:	416c8633          	sub	a2,s9,s6
    1a4c:	86ca                	mv	a3,s2
    1a4e:	85a6                	mv	a1,s1
    1a50:	9402                	jalr	s0
    1a52:	898bc50b          	th.lbuib	a0,(s7),-8,0
    1a56:	86ca                	mv	a3,s2
    1a58:	41bc8633          	sub	a2,s9,s11
    1a5c:	85a6                	mv	a1,s1
    1a5e:	8b6a                	mv	s6,s10
    1a60:	9402                	jalr	s0
    1a62:	f97c10e3          	bne	s8,s7,19e2 <_ftoa+0xb62>
    1a66:	7de2                	ld	s11,56(sp)
    1a68:	002a7a13          	andi	s4,s4,2
    1a6c:	140a0a63          	beqz	s4,1bc0 <_ftoa+0xd40>
    1a70:	413d09b3          	sub	s3,s10,s3
    1a74:	7c0aba8b          	th.extu	s5,s5,31,0
    1a78:	1559f463          	bgeu	s3,s5,1bc0 <_ftoa+0xd40>
    1a7c:	fff9cc13          	not	s8,s3
    1a80:	015c0e33          	add	t3,s8,s5
    1a84:	866a                	mv	a2,s10
    1a86:	001d0b13          	addi	s6,s10,1
    1a8a:	86ca                	mv	a3,s2
    1a8c:	85a6                	mv	a1,s1
    1a8e:	02000513          	li	a0,32
    1a92:	00198d13          	addi	s10,s3,1
    1a96:	007e7b93          	andi	s7,t3,7
    1a9a:	9402                	jalr	s0
    1a9c:	135d7263          	bgeu	s10,s5,1bc0 <_ftoa+0xd40>
    1aa0:	080b8e63          	beqz	s7,1b3c <_ftoa+0xcbc>
    1aa4:	4f05                	li	t5,1
    1aa6:	09eb8163          	beq	s7,t5,1b28 <_ftoa+0xca8>
    1aaa:	4309                	li	t1,2
    1aac:	066b8663          	beq	s7,t1,1b18 <_ftoa+0xc98>
    1ab0:	468d                	li	a3,3
    1ab2:	04db8b63          	beq	s7,a3,1b08 <_ftoa+0xc88>
    1ab6:	4811                	li	a6,4
    1ab8:	050b8063          	beq	s7,a6,1af8 <_ftoa+0xc78>
    1abc:	4715                	li	a4,5
    1abe:	02eb8563          	beq	s7,a4,1ae8 <_ftoa+0xc68>
    1ac2:	4519                	li	a0,6
    1ac4:	00ab8a63          	beq	s7,a0,1ad8 <_ftoa+0xc58>
    1ac8:	865a                	mv	a2,s6
    1aca:	86ca                	mv	a3,s2
    1acc:	85a6                	mv	a1,s1
    1ace:	02000513          	li	a0,32
    1ad2:	0b05                	addi	s6,s6,1
    1ad4:	9402                	jalr	s0
    1ad6:	0d05                	addi	s10,s10,1
    1ad8:	865a                	mv	a2,s6
    1ada:	86ca                	mv	a3,s2
    1adc:	85a6                	mv	a1,s1
    1ade:	02000513          	li	a0,32
    1ae2:	0b05                	addi	s6,s6,1
    1ae4:	9402                	jalr	s0
    1ae6:	0d05                	addi	s10,s10,1
    1ae8:	865a                	mv	a2,s6
    1aea:	86ca                	mv	a3,s2
    1aec:	85a6                	mv	a1,s1
    1aee:	02000513          	li	a0,32
    1af2:	0b05                	addi	s6,s6,1
    1af4:	9402                	jalr	s0
    1af6:	0d05                	addi	s10,s10,1
    1af8:	865a                	mv	a2,s6
    1afa:	86ca                	mv	a3,s2
    1afc:	85a6                	mv	a1,s1
    1afe:	02000513          	li	a0,32
    1b02:	0b05                	addi	s6,s6,1
    1b04:	9402                	jalr	s0
    1b06:	0d05                	addi	s10,s10,1
    1b08:	865a                	mv	a2,s6
    1b0a:	86ca                	mv	a3,s2
    1b0c:	85a6                	mv	a1,s1
    1b0e:	02000513          	li	a0,32
    1b12:	0b05                	addi	s6,s6,1
    1b14:	9402                	jalr	s0
    1b16:	0d05                	addi	s10,s10,1
    1b18:	865a                	mv	a2,s6
    1b1a:	86ca                	mv	a3,s2
    1b1c:	85a6                	mv	a1,s1
    1b1e:	02000513          	li	a0,32
    1b22:	0b05                	addi	s6,s6,1
    1b24:	9402                	jalr	s0
    1b26:	0d05                	addi	s10,s10,1
    1b28:	865a                	mv	a2,s6
    1b2a:	86ca                	mv	a3,s2
    1b2c:	85a6                	mv	a1,s1
    1b2e:	02000513          	li	a0,32
    1b32:	0d05                	addi	s10,s10,1
    1b34:	0b05                	addi	s6,s6,1
    1b36:	9402                	jalr	s0
    1b38:	095d7463          	bgeu	s10,s5,1bc0 <_ftoa+0xd40>
    1b3c:	865a                	mv	a2,s6
    1b3e:	86ca                	mv	a3,s2
    1b40:	85a6                	mv	a1,s1
    1b42:	02000513          	li	a0,32
    1b46:	9402                	jalr	s0
    1b48:	001b0c93          	addi	s9,s6,1
    1b4c:	8666                	mv	a2,s9
    1b4e:	86ca                	mv	a3,s2
    1b50:	85a6                	mv	a1,s1
    1b52:	02000513          	li	a0,32
    1b56:	9402                	jalr	s0
    1b58:	002b0993          	addi	s3,s6,2
    1b5c:	864e                	mv	a2,s3
    1b5e:	86ca                	mv	a3,s2
    1b60:	85a6                	mv	a1,s1
    1b62:	02000513          	li	a0,32
    1b66:	9402                	jalr	s0
    1b68:	003b0a13          	addi	s4,s6,3
    1b6c:	86ca                	mv	a3,s2
    1b6e:	8652                	mv	a2,s4
    1b70:	85a6                	mv	a1,s1
    1b72:	02000513          	li	a0,32
    1b76:	9402                	jalr	s0
    1b78:	004b0c13          	addi	s8,s6,4
    1b7c:	86ca                	mv	a3,s2
    1b7e:	8662                	mv	a2,s8
    1b80:	85a6                	mv	a1,s1
    1b82:	02000513          	li	a0,32
    1b86:	9402                	jalr	s0
    1b88:	005b0c93          	addi	s9,s6,5
    1b8c:	86ca                	mv	a3,s2
    1b8e:	8666                	mv	a2,s9
    1b90:	85a6                	mv	a1,s1
    1b92:	02000513          	li	a0,32
    1b96:	9402                	jalr	s0
    1b98:	006b0b93          	addi	s7,s6,6
    1b9c:	86ca                	mv	a3,s2
    1b9e:	865e                	mv	a2,s7
    1ba0:	85a6                	mv	a1,s1
    1ba2:	02000513          	li	a0,32
    1ba6:	9402                	jalr	s0
    1ba8:	007b0993          	addi	s3,s6,7
    1bac:	86ca                	mv	a3,s2
    1bae:	864e                	mv	a2,s3
    1bb0:	85a6                	mv	a1,s1
    1bb2:	02000513          	li	a0,32
    1bb6:	0d21                	addi	s10,s10,8
    1bb8:	0b21                	addi	s6,s6,8
    1bba:	9402                	jalr	s0
    1bbc:	f95d60e3          	bltu	s10,s5,1b3c <_ftoa+0xcbc>
    1bc0:	6d06                	ld	s10,64(sp)
    1bc2:	fc0ff06f          	j	1382 <_ftoa+0x502>
    1bc6:	0001                	nop
    1bc8:	6fa9                	lui	t6,0xa
    1bca:	4d0f8b93          	addi	s7,t6,1232 # a4d0 <__errno+0x224>
    1bce:	4c11                	li	s8,4
    1bd0:	cb8ff06f          	j	1088 <_ftoa+0x208>
    1bd4:	0aa1f553          	fsub.d	fa0,ft3,fa0
    1bd8:	4805                	li	a6,1
    1bda:	b20ff06f          	j	efa <_ftoa+0x7a>
    1bde:	0001                	nop
    1be0:	00387813          	andi	a6,a6,3
    1be4:	8c32                	mv	s8,a2
    1be6:	12081963          	bnez	a6,1d18 <_ftoa+0xe98>
    1bea:	4291                	li	t0,4
    1bec:	7c0ab50b          	th.extu	a0,s5,31,0
    1bf0:	1352f463          	bgeu	t0,s5,1d18 <_ftoa+0xe98>
    1bf4:	ffc60793          	addi	a5,a2,-4
    1bf8:	00a78c33          	add	s8,a5,a0
    1bfc:	40cc05b3          	sub	a1,s8,a2
    1c00:	0075fe93          	andi	t4,a1,7
    1c04:	8b32                	mv	s6,a2
    1c06:	080e8763          	beqz	t4,1c94 <_ftoa+0xe14>
    1c0a:	4605                	li	a2,1
    1c0c:	06ce8b63          	beq	t4,a2,1c82 <_ftoa+0xe02>
    1c10:	4689                	li	a3,2
    1c12:	06de8163          	beq	t4,a3,1c74 <_ftoa+0xdf4>
    1c16:	488d                	li	a7,3
    1c18:	051e8763          	beq	t4,a7,1c66 <_ftoa+0xde6>
    1c1c:	025e8e63          	beq	t4,t0,1c58 <_ftoa+0xdd8>
    1c20:	4f95                	li	t6,5
    1c22:	03fe8463          	beq	t4,t6,1c4a <_ftoa+0xdca>
    1c26:	4399                	li	t2,6
    1c28:	007e8a63          	beq	t4,t2,1c3c <_ftoa+0xdbc>
    1c2c:	86ca                	mv	a3,s2
    1c2e:	864e                	mv	a2,s3
    1c30:	85a6                	mv	a1,s1
    1c32:	02000513          	li	a0,32
    1c36:	00198b13          	addi	s6,s3,1
    1c3a:	9402                	jalr	s0
    1c3c:	865a                	mv	a2,s6
    1c3e:	86ca                	mv	a3,s2
    1c40:	85a6                	mv	a1,s1
    1c42:	02000513          	li	a0,32
    1c46:	0b05                	addi	s6,s6,1
    1c48:	9402                	jalr	s0
    1c4a:	865a                	mv	a2,s6
    1c4c:	86ca                	mv	a3,s2
    1c4e:	85a6                	mv	a1,s1
    1c50:	02000513          	li	a0,32
    1c54:	0b05                	addi	s6,s6,1
    1c56:	9402                	jalr	s0
    1c58:	865a                	mv	a2,s6
    1c5a:	86ca                	mv	a3,s2
    1c5c:	85a6                	mv	a1,s1
    1c5e:	02000513          	li	a0,32
    1c62:	0b05                	addi	s6,s6,1
    1c64:	9402                	jalr	s0
    1c66:	865a                	mv	a2,s6
    1c68:	86ca                	mv	a3,s2
    1c6a:	85a6                	mv	a1,s1
    1c6c:	02000513          	li	a0,32
    1c70:	0b05                	addi	s6,s6,1
    1c72:	9402                	jalr	s0
    1c74:	865a                	mv	a2,s6
    1c76:	86ca                	mv	a3,s2
    1c78:	85a6                	mv	a1,s1
    1c7a:	02000513          	li	a0,32
    1c7e:	0b05                	addi	s6,s6,1
    1c80:	9402                	jalr	s0
    1c82:	865a                	mv	a2,s6
    1c84:	86ca                	mv	a3,s2
    1c86:	0b05                	addi	s6,s6,1
    1c88:	85a6                	mv	a1,s1
    1c8a:	02000513          	li	a0,32
    1c8e:	9402                	jalr	s0
    1c90:	098b0463          	beq	s6,s8,1d18 <_ftoa+0xe98>
    1c94:	865a                	mv	a2,s6
    1c96:	86ca                	mv	a3,s2
    1c98:	85a6                	mv	a1,s1
    1c9a:	02000513          	li	a0,32
    1c9e:	9402                	jalr	s0
    1ca0:	001b0b93          	addi	s7,s6,1
    1ca4:	865e                	mv	a2,s7
    1ca6:	86ca                	mv	a3,s2
    1ca8:	85a6                	mv	a1,s1
    1caa:	02000513          	li	a0,32
    1cae:	9402                	jalr	s0
    1cb0:	002b0c93          	addi	s9,s6,2
    1cb4:	8666                	mv	a2,s9
    1cb6:	86ca                	mv	a3,s2
    1cb8:	85a6                	mv	a1,s1
    1cba:	02000513          	li	a0,32
    1cbe:	9402                	jalr	s0
    1cc0:	003b0b93          	addi	s7,s6,3
    1cc4:	865e                	mv	a2,s7
    1cc6:	86ca                	mv	a3,s2
    1cc8:	85a6                	mv	a1,s1
    1cca:	02000513          	li	a0,32
    1cce:	9402                	jalr	s0
    1cd0:	004b0c93          	addi	s9,s6,4
    1cd4:	8666                	mv	a2,s9
    1cd6:	86ca                	mv	a3,s2
    1cd8:	85a6                	mv	a1,s1
    1cda:	02000513          	li	a0,32
    1cde:	9402                	jalr	s0
    1ce0:	005b0b93          	addi	s7,s6,5
    1ce4:	865e                	mv	a2,s7
    1ce6:	86ca                	mv	a3,s2
    1ce8:	85a6                	mv	a1,s1
    1cea:	02000513          	li	a0,32
    1cee:	9402                	jalr	s0
    1cf0:	006b0c93          	addi	s9,s6,6
    1cf4:	86ca                	mv	a3,s2
    1cf6:	8666                	mv	a2,s9
    1cf8:	85a6                	mv	a1,s1
    1cfa:	02000513          	li	a0,32
    1cfe:	9402                	jalr	s0
    1d00:	007b0b93          	addi	s7,s6,7
    1d04:	86ca                	mv	a3,s2
    1d06:	0b21                	addi	s6,s6,8
    1d08:	865e                	mv	a2,s7
    1d0a:	85a6                	mv	a1,s1
    1d0c:	02000513          	li	a0,32
    1d10:	9402                	jalr	s0
    1d12:	f98b11e3          	bne	s6,s8,1c94 <_ftoa+0xe14>
    1d16:	0001                	nop
    1d18:	6729                	lui	a4,0xa
    1d1a:	4e870b13          	addi	s6,a4,1256 # a4e8 <__errno+0x23c>
    1d1e:	ffcb0c93          	addi	s9,s6,-4
    1d22:	018b0bb3          	add	s7,s6,s8
    1d26:	0001                	nop
    1d28:	003b4503          	lbu	a0,3(s6)
    1d2c:	416b8633          	sub	a2,s7,s6
    1d30:	86ca                	mv	a3,s2
    1d32:	85a6                	mv	a1,s1
    1d34:	1b7d                	addi	s6,s6,-1
    1d36:	9402                	jalr	s0
    1d38:	ff6c98e3          	bne	s9,s6,1d28 <_ftoa+0xea8>
    1d3c:	002a7e13          	andi	t3,s4,2
    1d40:	004c0b13          	addi	s6,s8,4
    1d44:	e20e0f63          	beqz	t3,1382 <_ftoa+0x502>
    1d48:	7c0aba8b          	th.extu	s5,s5,31,0
    1d4c:	413b0f33          	sub	t5,s6,s3
    1d50:	e35f7963          	bgeu	t5,s5,1382 <_ftoa+0x502>
    1d54:	fffb4313          	not	t1,s6
    1d58:	01530a33          	add	s4,t1,s5
    1d5c:	013a0833          	add	a6,s4,s3
    1d60:	865a                	mv	a2,s6
    1d62:	02000513          	li	a0,32
    1d66:	86ca                	mv	a3,s2
    1d68:	85a6                	mv	a1,s1
    1d6a:	00787c93          	andi	s9,a6,7
    1d6e:	005c0b13          	addi	s6,s8,5
    1d72:	9402                	jalr	s0
    1d74:	413b0533          	sub	a0,s6,s3
    1d78:	e1557563          	bgeu	a0,s5,1382 <_ftoa+0x502>
    1d7c:	080c8963          	beqz	s9,1e0e <_ftoa+0xf8e>
    1d80:	4285                	li	t0,1
    1d82:	065c8b63          	beq	s9,t0,1df8 <_ftoa+0xf78>
    1d86:	4789                	li	a5,2
    1d88:	06fc8163          	beq	s9,a5,1dea <_ftoa+0xf6a>
    1d8c:	4c0d                	li	s8,3
    1d8e:	058c8763          	beq	s9,s8,1ddc <_ftoa+0xf5c>
    1d92:	4591                	li	a1,4
    1d94:	02bc8d63          	beq	s9,a1,1dce <_ftoa+0xf4e>
    1d98:	4e95                	li	t4,5
    1d9a:	03dc8363          	beq	s9,t4,1dc0 <_ftoa+0xf40>
    1d9e:	4619                	li	a2,6
    1da0:	00cc8963          	beq	s9,a2,1db2 <_ftoa+0xf32>
    1da4:	865a                	mv	a2,s6
    1da6:	86ca                	mv	a3,s2
    1da8:	85a6                	mv	a1,s1
    1daa:	02000513          	li	a0,32
    1dae:	0b05                	addi	s6,s6,1
    1db0:	9402                	jalr	s0
    1db2:	865a                	mv	a2,s6
    1db4:	86ca                	mv	a3,s2
    1db6:	85a6                	mv	a1,s1
    1db8:	02000513          	li	a0,32
    1dbc:	0b05                	addi	s6,s6,1
    1dbe:	9402                	jalr	s0
    1dc0:	865a                	mv	a2,s6
    1dc2:	86ca                	mv	a3,s2
    1dc4:	85a6                	mv	a1,s1
    1dc6:	02000513          	li	a0,32
    1dca:	0b05                	addi	s6,s6,1
    1dcc:	9402                	jalr	s0
    1dce:	865a                	mv	a2,s6
    1dd0:	86ca                	mv	a3,s2
    1dd2:	85a6                	mv	a1,s1
    1dd4:	02000513          	li	a0,32
    1dd8:	0b05                	addi	s6,s6,1
    1dda:	9402                	jalr	s0
    1ddc:	865a                	mv	a2,s6
    1dde:	86ca                	mv	a3,s2
    1de0:	85a6                	mv	a1,s1
    1de2:	02000513          	li	a0,32
    1de6:	0b05                	addi	s6,s6,1
    1de8:	9402                	jalr	s0
    1dea:	865a                	mv	a2,s6
    1dec:	86ca                	mv	a3,s2
    1dee:	85a6                	mv	a1,s1
    1df0:	02000513          	li	a0,32
    1df4:	0b05                	addi	s6,s6,1
    1df6:	9402                	jalr	s0
    1df8:	865a                	mv	a2,s6
    1dfa:	86ca                	mv	a3,s2
    1dfc:	85a6                	mv	a1,s1
    1dfe:	02000513          	li	a0,32
    1e02:	0b05                	addi	s6,s6,1
    1e04:	9402                	jalr	s0
    1e06:	413b06b3          	sub	a3,s6,s3
    1e0a:	d756fc63          	bgeu	a3,s5,1382 <_ftoa+0x502>
    1e0e:	865a                	mv	a2,s6
    1e10:	86ca                	mv	a3,s2
    1e12:	85a6                	mv	a1,s1
    1e14:	02000513          	li	a0,32
    1e18:	9402                	jalr	s0
    1e1a:	001b0a13          	addi	s4,s6,1
    1e1e:	8652                	mv	a2,s4
    1e20:	86ca                	mv	a3,s2
    1e22:	85a6                	mv	a1,s1
    1e24:	02000513          	li	a0,32
    1e28:	9402                	jalr	s0
    1e2a:	002b0b93          	addi	s7,s6,2
    1e2e:	865e                	mv	a2,s7
    1e30:	86ca                	mv	a3,s2
    1e32:	85a6                	mv	a1,s1
    1e34:	02000513          	li	a0,32
    1e38:	9402                	jalr	s0
    1e3a:	003b0c93          	addi	s9,s6,3
    1e3e:	8666                	mv	a2,s9
    1e40:	86ca                	mv	a3,s2
    1e42:	85a6                	mv	a1,s1
    1e44:	02000513          	li	a0,32
    1e48:	9402                	jalr	s0
    1e4a:	004b0c13          	addi	s8,s6,4
    1e4e:	86ca                	mv	a3,s2
    1e50:	8662                	mv	a2,s8
    1e52:	85a6                	mv	a1,s1
    1e54:	02000513          	li	a0,32
    1e58:	9402                	jalr	s0
    1e5a:	005b0a13          	addi	s4,s6,5
    1e5e:	86ca                	mv	a3,s2
    1e60:	8652                	mv	a2,s4
    1e62:	85a6                	mv	a1,s1
    1e64:	02000513          	li	a0,32
    1e68:	9402                	jalr	s0
    1e6a:	006b0b93          	addi	s7,s6,6
    1e6e:	86ca                	mv	a3,s2
    1e70:	865e                	mv	a2,s7
    1e72:	85a6                	mv	a1,s1
    1e74:	02000513          	li	a0,32
    1e78:	9402                	jalr	s0
    1e7a:	007b0c93          	addi	s9,s6,7
    1e7e:	86ca                	mv	a3,s2
    1e80:	8666                	mv	a2,s9
    1e82:	85a6                	mv	a1,s1
    1e84:	02000513          	li	a0,32
    1e88:	0b21                	addi	s6,s6,8
    1e8a:	9402                	jalr	s0
    1e8c:	413b06b3          	sub	a3,s6,s3
    1e90:	f756efe3          	bltu	a3,s5,1e0e <_ftoa+0xf8e>
    1e94:	ceeff06f          	j	1382 <_ftoa+0x502>
    1e98:	4e85                	li	t4,1
    1e9a:	418e8633          	sub	a2,t4,s8
    1e9e:	003a7593          	andi	a1,s4,3
    1ea2:	00f60fb3          	add	t6,a2,a5
    1ea6:	1dd58fe3          	beq	a1,t4,2884 <_ftoa+0x1a04>
    1eaa:	02000393          	li	t2,32
    1eae:	107f8be3          	beq	t6,t2,27c4 <_ftoa+0x1944>
    1eb2:	04080be3          	beqz	a6,2708 <_ftoa+0x1888>
    1eb6:	007f8333          	add	t1,t6,t2
    1eba:	00230733          	add	a4,t1,sp
    1ebe:	02d00513          	li	a0,45
    1ec2:	001f8b13          	addi	s6,t6,1
    1ec6:	fea70823          	sb	a0,-16(a4)
    1eca:	a80592e3          	bnez	a1,194e <_ftoa+0xace>
    1ece:	7c0ab28b          	th.extu	t0,s5,31,0
    1ed2:	a65b7ee3          	bgeu	s6,t0,194e <_ftoa+0xace>
    1ed6:	416285b3          	sub	a1,t0,s6
    1eda:	0075f793          	andi	a5,a1,7
    1ede:	01358d33          	add	s10,a1,s3
    1ee2:	8bce                	mv	s7,s3
    1ee4:	c7d9                	beqz	a5,1f72 <_ftoa+0x10f2>
    1ee6:	4e85                	li	t4,1
    1ee8:	07d78c63          	beq	a5,t4,1f60 <_ftoa+0x10e0>
    1eec:	4609                	li	a2,2
    1eee:	06c78263          	beq	a5,a2,1f52 <_ftoa+0x10d2>
    1ef2:	438d                	li	t2,3
    1ef4:	04778863          	beq	a5,t2,1f44 <_ftoa+0x10c4>
    1ef8:	4891                	li	a7,4
    1efa:	03178e63          	beq	a5,a7,1f36 <_ftoa+0x10b6>
    1efe:	4e15                	li	t3,5
    1f00:	03c78463          	beq	a5,t3,1f28 <_ftoa+0x10a8>
    1f04:	4f19                	li	t5,6
    1f06:	01e78a63          	beq	a5,t5,1f1a <_ftoa+0x109a>
    1f0a:	86ca                	mv	a3,s2
    1f0c:	864e                	mv	a2,s3
    1f0e:	85a6                	mv	a1,s1
    1f10:	02000513          	li	a0,32
    1f14:	00198b93          	addi	s7,s3,1
    1f18:	9402                	jalr	s0
    1f1a:	865e                	mv	a2,s7
    1f1c:	86ca                	mv	a3,s2
    1f1e:	85a6                	mv	a1,s1
    1f20:	02000513          	li	a0,32
    1f24:	0b85                	addi	s7,s7,1
    1f26:	9402                	jalr	s0
    1f28:	865e                	mv	a2,s7
    1f2a:	86ca                	mv	a3,s2
    1f2c:	85a6                	mv	a1,s1
    1f2e:	02000513          	li	a0,32
    1f32:	0b85                	addi	s7,s7,1
    1f34:	9402                	jalr	s0
    1f36:	865e                	mv	a2,s7
    1f38:	86ca                	mv	a3,s2
    1f3a:	85a6                	mv	a1,s1
    1f3c:	02000513          	li	a0,32
    1f40:	0b85                	addi	s7,s7,1
    1f42:	9402                	jalr	s0
    1f44:	865e                	mv	a2,s7
    1f46:	86ca                	mv	a3,s2
    1f48:	85a6                	mv	a1,s1
    1f4a:	02000513          	li	a0,32
    1f4e:	0b85                	addi	s7,s7,1
    1f50:	9402                	jalr	s0
    1f52:	865e                	mv	a2,s7
    1f54:	86ca                	mv	a3,s2
    1f56:	85a6                	mv	a1,s1
    1f58:	02000513          	li	a0,32
    1f5c:	0b85                	addi	s7,s7,1
    1f5e:	9402                	jalr	s0
    1f60:	865e                	mv	a2,s7
    1f62:	86ca                	mv	a3,s2
    1f64:	0b85                	addi	s7,s7,1
    1f66:	85a6                	mv	a1,s1
    1f68:	02000513          	li	a0,32
    1f6c:	9402                	jalr	s0
    1f6e:	9f7d01e3          	beq	s10,s7,1950 <_ftoa+0xad0>
    1f72:	fc6e                	sd	s11,56(sp)
    1f74:	865e                	mv	a2,s7
    1f76:	86ca                	mv	a3,s2
    1f78:	85a6                	mv	a1,s1
    1f7a:	02000513          	li	a0,32
    1f7e:	9402                	jalr	s0
    1f80:	001b8c93          	addi	s9,s7,1
    1f84:	8666                	mv	a2,s9
    1f86:	86ca                	mv	a3,s2
    1f88:	85a6                	mv	a1,s1
    1f8a:	02000513          	li	a0,32
    1f8e:	9402                	jalr	s0
    1f90:	002b8d93          	addi	s11,s7,2
    1f94:	866e                	mv	a2,s11
    1f96:	86ca                	mv	a3,s2
    1f98:	85a6                	mv	a1,s1
    1f9a:	02000513          	li	a0,32
    1f9e:	9402                	jalr	s0
    1fa0:	003b8c93          	addi	s9,s7,3
    1fa4:	8666                	mv	a2,s9
    1fa6:	86ca                	mv	a3,s2
    1fa8:	85a6                	mv	a1,s1
    1faa:	02000513          	li	a0,32
    1fae:	9402                	jalr	s0
    1fb0:	004b8d93          	addi	s11,s7,4
    1fb4:	866e                	mv	a2,s11
    1fb6:	86ca                	mv	a3,s2
    1fb8:	85a6                	mv	a1,s1
    1fba:	02000513          	li	a0,32
    1fbe:	9402                	jalr	s0
    1fc0:	005b8c93          	addi	s9,s7,5
    1fc4:	8666                	mv	a2,s9
    1fc6:	86ca                	mv	a3,s2
    1fc8:	85a6                	mv	a1,s1
    1fca:	02000513          	li	a0,32
    1fce:	9402                	jalr	s0
    1fd0:	006b8d93          	addi	s11,s7,6
    1fd4:	86ca                	mv	a3,s2
    1fd6:	866e                	mv	a2,s11
    1fd8:	85a6                	mv	a1,s1
    1fda:	02000513          	li	a0,32
    1fde:	9402                	jalr	s0
    1fe0:	007b8c93          	addi	s9,s7,7
    1fe4:	86ca                	mv	a3,s2
    1fe6:	0ba1                	addi	s7,s7,8
    1fe8:	8666                	mv	a2,s9
    1fea:	85a6                	mv	a1,s1
    1fec:	02000513          	li	a0,32
    1ff0:	9402                	jalr	s0
    1ff2:	f97d11e3          	bne	s10,s7,1f74 <_ftoa+0x10f4>
    1ff6:	7de2                	ld	s11,56(sp)
    1ff8:	baa1                	j	1950 <_ftoa+0xad0>
    1ffa:	0001                	nop
    1ffc:	4305                	li	t1,1
    1ffe:	41830733          	sub	a4,t1,s8
    2002:	00c702b3          	add	t0,a4,a2
    2006:	02000393          	li	t2,32
    200a:	0e728363          	beq	t0,t2,20f0 <_ftoa+0x1270>
    200e:	7c0eb50b          	th.extu	a0,t4,31,0
    2012:	00757b93          	andi	s7,a0,7
    2016:	00550b33          	add	s6,a0,t0
    201a:	03000893          	li	a7,48
    201e:	060b8663          	beqz	s7,208a <_ftoa+0x120a>
    2022:	005c588b          	th.srb	a7,s8,t0,0
    2026:	0285                	addi	t0,t0,1
    2028:	0c728463          	beq	t0,t2,20f0 <_ftoa+0x1270>
    202c:	046b8f63          	beq	s7,t1,208a <_ftoa+0x120a>
    2030:	4c89                	li	s9,2
    2032:	059b8763          	beq	s7,s9,2080 <_ftoa+0x1200>
    2036:	4d0d                	li	s10,3
    2038:	03ab8f63          	beq	s7,s10,2076 <_ftoa+0x11f6>
    203c:	4e11                	li	t3,4
    203e:	03cb8763          	beq	s7,t3,206c <_ftoa+0x11ec>
    2042:	4e95                	li	t4,5
    2044:	01db8f63          	beq	s7,t4,2062 <_ftoa+0x11e2>
    2048:	4f19                	li	t5,6
    204a:	01eb8763          	beq	s7,t5,2058 <_ftoa+0x11d8>
    204e:	005c588b          	th.srb	a7,s8,t0,0
    2052:	0285                	addi	t0,t0,1
    2054:	08728e63          	beq	t0,t2,20f0 <_ftoa+0x1270>
    2058:	005c588b          	th.srb	a7,s8,t0,0
    205c:	0285                	addi	t0,t0,1
    205e:	08728963          	beq	t0,t2,20f0 <_ftoa+0x1270>
    2062:	005c588b          	th.srb	a7,s8,t0,0
    2066:	0285                	addi	t0,t0,1
    2068:	08728463          	beq	t0,t2,20f0 <_ftoa+0x1270>
    206c:	005c588b          	th.srb	a7,s8,t0,0
    2070:	0285                	addi	t0,t0,1
    2072:	06728f63          	beq	t0,t2,20f0 <_ftoa+0x1270>
    2076:	005c588b          	th.srb	a7,s8,t0,0
    207a:	0285                	addi	t0,t0,1
    207c:	06728a63          	beq	t0,t2,20f0 <_ftoa+0x1270>
    2080:	005c588b          	th.srb	a7,s8,t0,0
    2084:	0285                	addi	t0,t0,1
    2086:	06728563          	beq	t0,t2,20f0 <_ftoa+0x1270>
    208a:	665b0463          	beq	s6,t0,26f2 <_ftoa+0x1872>
    208e:	005c588b          	th.srb	a7,s8,t0,0
    2092:	00128f93          	addi	t6,t0,1
    2096:	047f8d63          	beq	t6,t2,20f0 <_ftoa+0x1270>
    209a:	01fc588b          	th.srb	a7,s8,t6,0
    209e:	00228313          	addi	t1,t0,2
    20a2:	04730763          	beq	t1,t2,20f0 <_ftoa+0x1270>
    20a6:	006c588b          	th.srb	a7,s8,t1,0
    20aa:	00328713          	addi	a4,t0,3
    20ae:	04770163          	beq	a4,t2,20f0 <_ftoa+0x1270>
    20b2:	00ec588b          	th.srb	a7,s8,a4,0
    20b6:	00428513          	addi	a0,t0,4
    20ba:	02750b63          	beq	a0,t2,20f0 <_ftoa+0x1270>
    20be:	00ac588b          	th.srb	a7,s8,a0,0
    20c2:	00528b93          	addi	s7,t0,5
    20c6:	027b8563          	beq	s7,t2,20f0 <_ftoa+0x1270>
    20ca:	017c588b          	th.srb	a7,s8,s7,0
    20ce:	00628c93          	addi	s9,t0,6
    20d2:	007c8f63          	beq	s9,t2,20f0 <_ftoa+0x1270>
    20d6:	019c588b          	th.srb	a7,s8,s9,0
    20da:	00728d13          	addi	s10,t0,7
    20de:	007d0963          	beq	s10,t2,20f0 <_ftoa+0x1270>
    20e2:	01ac588b          	th.srb	a7,s8,s10,0
    20e6:	02a1                	addi	t0,t0,8
    20e8:	fa7291e3          	bne	t0,t2,208a <_ftoa+0x120a>
    20ec:	00000013          	nop
    20f0:	02000f93          	li	t6,32
    20f4:	d8cff06f          	j	1680 <_ftoa+0x800>
    20f8:	e20506d3          	fmv.x.d	a3,fa0
    20fc:	fc6e                	sd	s11,56(sp)
    20fe:	fb46b58b          	th.extu	a1,a3,62,52
    2102:	6ea9                	lui	t4,0xa
    2104:	6629                	lui	a2,0xa
    2106:	710ebf07          	fld	ft10,1808(t4) # a710 <pow10.0+0x70>
    210a:	71863f87          	fld	ft11,1816(a2) # a718 <pow10.0+0x78>
    210e:	c015879b          	addiw	a5,a1,-1023
    2112:	d2078ed3          	fcvt.d.w	ft9,a5
    2116:	3ff00893          	li	a7,1023
    211a:	6e29                	lui	t3,0xa
    211c:	03489b13          	slli	s6,a7,0x34
    2120:	720e3787          	fld	fa5,1824(t3) # a720 <pow10.0+0x80>
    2124:	cc06b38b          	th.extu	t2,a3,51,0
    2128:	fbeef043          	fmadd.d	ft0,ft9,ft10,ft11
    212c:	0163edb3          	or	s11,t2,s6
    2130:	f20d80d3          	fmv.d.x	ft1,s11
    2134:	6f29                	lui	t5,0xa
    2136:	0af0f153          	fsub.d	ft2,ft1,fa5
    213a:	728f3187          	fld	ft3,1832(t5) # a728 <pow10.0+0x88>
    213e:	6829                	lui	a6,0xa
    2140:	6529                	lui	a0,0xa
    2142:	023176c3          	fmadd.d	fa3,ft2,ft3,ft0
    2146:	73083287          	fld	ft5,1840(a6) # a730 <pow10.0+0x90>
    214a:	73853307          	fld	ft6,1848(a0) # a738 <pow10.0+0x98>
    214e:	6c29                	lui	s8,0xa
    2150:	740c3587          	fld	fa1,1856(s8) # a740 <pow10.0+0xa0>
    2154:	c2069353          	fcvt.w.d	t1,fa3,rtz
    2158:	6ba9                	lui	s7,0xa
    215a:	d2030253          	fcvt.d.w	ft4,t1
    215e:	748bb807          	fld	fa6,1864(s7) # a748 <pow10.0+0xa8>
    2162:	32527743          	fmadd.d	fa4,ft4,ft5,ft6
    2166:	4299                	li	t0,6
    2168:	400a7f93          	andi	t6,s4,1024
    216c:	41f2970b          	th.mveqz	a4,t0,t6
    2170:	62a9                	lui	t0,0xa
    2172:	c2071d53          	fcvt.w.d	s10,fa4,rtz
    2176:	7502bf07          	fld	ft10,1872(t0) # a750 <pow10.0+0xb0>
    217a:	d20d03d3          	fcvt.d.w	ft7,s10
    217e:	65a9                	lui	a1,0xa
    2180:	12b3f653          	fmul.d	fa2,ft7,fa1
    2184:	7585b087          	fld	ft1,1880(a1) # a758 <pow10.0+0xb8>
    2188:	67a9                	lui	a5,0xa
    218a:	7607b107          	fld	ft2,1888(a5) # a760 <pow10.0+0xc0>
    218e:	630278c7          	fmsub.d	fa7,ft4,fa6,fa2
    2192:	6ea9                	lui	t4,0xa
    2194:	768eb207          	fld	ft4,1896(t4) # a768 <pow10.0+0xc8>
    2198:	6629                	lui	a2,0xa
    219a:	77063707          	fld	fa4,1904(a2) # a770 <pow10.0+0xd0>
    219e:	1318fe53          	fmul.d	ft8,fa7,fa7
    21a2:	0b1272d3          	fsub.d	ft5,ft4,fa7
    21a6:	0318fed3          	fadd.d	ft9,fa7,fa7
    21aa:	3ffd039b          	addiw	t2,s10,1023
    21ae:	1bee7fd3          	fdiv.d	ft11,ft8,ft10
    21b2:	03439893          	slli	a7,t2,0x34
    21b6:	f2088653          	fmv.d.x	fa2,a7
    21ba:	f2068853          	fmv.d.x	fa6,a3
    21be:	00030c9b          	sext.w	s9,t1
    21c2:	021ff053          	fadd.d	ft0,ft11,ft1
    21c6:	1a0e77d3          	fdiv.d	fa5,ft8,ft0
    21ca:	0227f1d3          	fadd.d	ft3,fa5,ft2
    21ce:	1a3e76d3          	fdiv.d	fa3,ft8,ft3
    21d2:	0256f353          	fadd.d	ft6,fa3,ft5
    21d6:	1a6ef3d3          	fdiv.d	ft7,ft9,ft6
    21da:	02e3f5d3          	fadd.d	fa1,ft7,fa4
    21de:	12c5f8d3          	fmul.d	fa7,fa1,fa2
    21e2:	a3181b53          	flt.d	s6,fa6,fa7
    21e6:	000b0663          	beqz	s6,21f2 <_ftoa+0x1372>
    21ea:	1a18f8d3          	fdiv.d	fa7,fa7,ft1
    21ee:	fff30c9b          	addiw	s9,t1,-1
    21f2:	6505                	lui	a0,0x1
    21f4:	063c8d9b          	addiw	s11,s9,99
    21f8:	0c600e13          	li	t3,198
    21fc:	80050c13          	addi	s8,a0,-2048 # 800 <Proc_5>
    2200:	01be3f33          	sltu	t5,t3,s11
    2204:	4b89                	li	s7,2
    2206:	4d0d                	li	s10,3
    2208:	4315                	li	t1,5
    220a:	4811                	li	a6,4
    220c:	018a77b3          	and	a5,s4,s8
    2210:	41eb9d0b          	th.mveqz	s10,s7,t5
    2214:	41e8130b          	th.mveqz	t1,a6,t5
    2218:	50078c63          	beqz	a5,2730 <_ftoa+0x18b0>
    221c:	fff7059b          	addiw	a1,a4,-1
    2220:	41f7158b          	th.mveqz	a1,a4,t6
    2224:	406a87bb          	subw	a5,s5,t1
    2228:	01533eb3          	sltu	t4,t1,s5
    222c:	002a7613          	andi	a2,s4,2
    2230:	42e5970b          	th.mvnez	a4,a1,a4
    2234:	41d0178b          	th.mveqz	a5,zero,t4
    2238:	50060263          	beqz	a2,273c <_ftoa+0x18bc>
    223c:	4781                	li	a5,0
    223e:	0001                	nop
    2240:	000c8863          	beqz	s9,2250 <_ftoa+0x13d0>
    2244:	f2068e53          	fmv.d.x	ft8,a3
    2248:	1b1e7ed3          	fdiv.d	ft9,ft8,fa7
    224c:	e20e86d3          	fmv.x.d	a3,ft9
    2250:	f2000f53          	fmv.d.x	ft10,zero
    2254:	a3e513d3          	flt.d	t2,fa0,ft10
    2258:	00038863          	beqz	t2,2268 <_ftoa+0x13e8>
    225c:	f2068553          	fmv.d.x	fa0,a3
    2260:	22a51fd3          	fneg.d	ft11,fa0
    2264:	e20f86d3          	fmv.x.d	a3,ft11
    2268:	78fd                	lui	a7,0xfffff
    226a:	7ff88b13          	addi	s6,a7,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    226e:	016a7833          	and	a6,s4,s6
    2272:	f2068553          	fmv.d.x	fa0,a3
    2276:	864e                	mv	a2,s3
    2278:	86ca                	mv	a3,s2
    227a:	85a6                	mv	a1,s1
    227c:	8522                	mv	a0,s0
    227e:	c03fe0ef          	jal	e80 <_ftoa>
    2282:	020a7713          	andi	a4,s4,32
    2286:	862a                	mv	a2,a0
    2288:	00150a13          	addi	s4,a0,1
    228c:	06500793          	li	a5,101
    2290:	8daa                	mv	s11,a0
    2292:	04500513          	li	a0,69
    2296:	e452                	sd	s4,8(sp)
    2298:	86ca                	mv	a3,s2
    229a:	40e7950b          	th.mveqz	a0,a5,a4
    229e:	85a6                	mv	a1,s1
    22a0:	9402                	jalr	s0
    22a2:	41fcde1b          	sraiw	t3,s9,0x1f
    22a6:	01cccf33          	xor	t5,s9,t3
    22aa:	41cf033b          	subw	t1,t5,t3
    22ae:	4c29                	li	s8,10
    22b0:	03837833          	remu	a6,t1,s8
    22b4:	01010a13          	addi	s4,sp,16
    22b8:	4fa5                	li	t6,9
    22ba:	86d2                	mv	a3,s4
    22bc:	0308051b          	addiw	a0,a6,48
    22c0:	00aa0023          	sb	a0,0(s4)
    22c4:	038358b3          	divu	a7,t1,s8
    22c8:	106ff863          	bgeu	t6,t1,23d8 <_ftoa+0x1558>
    22cc:	01110693          	addi	a3,sp,17
    22d0:	0388f2b3          	remu	t0,a7,s8
    22d4:	0302859b          	addiw	a1,t0,48
    22d8:	00b68023          	sb	a1,0(a3)
    22dc:	0388deb3          	divu	t4,a7,s8
    22e0:	0f1ffc63          	bgeu	t6,a7,23d8 <_ftoa+0x1558>
    22e4:	00168393          	addi	t2,a3,1
    22e8:	1810                	addi	a2,sp,48
    22ea:	0e760763          	beq	a2,t2,23d8 <_ftoa+0x1558>
    22ee:	869e                	mv	a3,t2
    22f0:	038ef8b3          	remu	a7,t4,s8
    22f4:	03088b1b          	addiw	s6,a7,48
    22f8:	01638023          	sb	s6,0(t2)
    22fc:	038ed733          	divu	a4,t4,s8
    2300:	0ddffc63          	bgeu	t6,t4,23d8 <_ftoa+0x1558>
    2304:	038777b3          	remu	a5,a4,s8
    2308:	03078e1b          	addiw	t3,a5,48
    230c:	0816de0b          	th.sbib	t3,(a3),1,0
    2310:	03875f33          	divu	t5,a4,s8
    2314:	0ceff263          	bgeu	t6,a4,23d8 <_ftoa+0x1558>
    2318:	00238693          	addi	a3,t2,2
    231c:	038f7333          	remu	t1,t5,s8
    2320:	0303081b          	addiw	a6,t1,48
    2324:	01038123          	sb	a6,2(t2)
    2328:	038f5533          	divu	a0,t5,s8
    232c:	0beff663          	bgeu	t6,t5,23d8 <_ftoa+0x1558>
    2330:	00338693          	addi	a3,t2,3
    2334:	038572b3          	remu	t0,a0,s8
    2338:	0302859b          	addiw	a1,t0,48
    233c:	00b381a3          	sb	a1,3(t2)
    2340:	03855eb3          	divu	t4,a0,s8
    2344:	08affa63          	bgeu	t6,a0,23d8 <_ftoa+0x1558>
    2348:	00438693          	addi	a3,t2,4
    234c:	038ef633          	remu	a2,t4,s8
    2350:	0306089b          	addiw	a7,a2,48
    2354:	01138223          	sb	a7,4(t2)
    2358:	038edb33          	divu	s6,t4,s8
    235c:	07dffe63          	bgeu	t6,t4,23d8 <_ftoa+0x1558>
    2360:	00538693          	addi	a3,t2,5
    2364:	038b7733          	remu	a4,s6,s8
    2368:	0307079b          	addiw	a5,a4,48
    236c:	00f382a3          	sb	a5,5(t2)
    2370:	038b5e33          	divu	t3,s6,s8
    2374:	076ff263          	bgeu	t6,s6,23d8 <_ftoa+0x1558>
    2378:	00638693          	addi	a3,t2,6
    237c:	038e7f33          	remu	t5,t3,s8
    2380:	030f031b          	addiw	t1,t5,48
    2384:	00638323          	sb	t1,6(t2)
    2388:	038e5833          	divu	a6,t3,s8
    238c:	05cff663          	bgeu	t6,t3,23d8 <_ftoa+0x1558>
    2390:	00738693          	addi	a3,t2,7
    2394:	03887533          	remu	a0,a6,s8
    2398:	0305029b          	addiw	t0,a0,48
    239c:	005383a3          	sb	t0,7(t2)
    23a0:	038855b3          	divu	a1,a6,s8
    23a4:	030ffa63          	bgeu	t6,a6,23d8 <_ftoa+0x1558>
    23a8:	00838693          	addi	a3,t2,8
    23ac:	0385feb3          	remu	t4,a1,s8
    23b0:	030e861b          	addiw	a2,t4,48
    23b4:	00c38423          	sb	a2,8(t2)
    23b8:	0385d8b3          	divu	a7,a1,s8
    23bc:	00bffe63          	bgeu	t6,a1,23d8 <_ftoa+0x1558>
    23c0:	00938693          	addi	a3,t2,9
    23c4:	0388f2b3          	remu	t0,a7,s8
    23c8:	0302859b          	addiw	a1,t0,48
    23cc:	00b68023          	sb	a1,0(a3)
    23d0:	0388deb3          	divu	t4,a7,s8
    23d4:	f11fe8e3          	bltu	t6,a7,22e4 <_ftoa+0x1464>
    23d8:	4c05                	li	s8,1
    23da:	414c0fb3          	sub	t6,s8,s4
    23de:	00df8b33          	add	s6,t6,a3
    23e2:	43ab7d63          	bgeu	s6,s10,281c <_ftoa+0x199c>
    23e6:	016a07b3          	add	a5,s4,s6
    23ea:	01aa03b3          	add	t2,s4,s10
    23ee:	40f386b3          	sub	a3,t2,a5
    23f2:	0076fe13          	andi	t3,a3,7
    23f6:	03000713          	li	a4,48
    23fa:	380e0b63          	beqz	t3,2790 <_ftoa+0x1910>
    23fe:	038e0d63          	beq	t3,s8,2438 <_ftoa+0x15b8>
    2402:	4f09                	li	t5,2
    2404:	03ee0863          	beq	t3,t5,2434 <_ftoa+0x15b4>
    2408:	430d                	li	t1,3
    240a:	026e0363          	beq	t3,t1,2430 <_ftoa+0x15b0>
    240e:	4811                	li	a6,4
    2410:	010e0e63          	beq	t3,a6,242c <_ftoa+0x15ac>
    2414:	4515                	li	a0,5
    2416:	00ae0963          	beq	t3,a0,2428 <_ftoa+0x15a8>
    241a:	4299                	li	t0,6
    241c:	005e0463          	beq	t3,t0,2424 <_ftoa+0x15a4>
    2420:	1817d70b          	th.sbia	a4,(a5),1,0
    2424:	1817d70b          	th.sbia	a4,(a5),1,0
    2428:	1817d70b          	th.sbia	a4,(a5),1,0
    242c:	1817d70b          	th.sbia	a4,(a5),1,0
    2430:	1817d70b          	th.sbia	a4,(a5),1,0
    2434:	1817d70b          	th.sbia	a4,(a5),1,0
    2438:	1817d70b          	th.sbia	a4,(a5),1,0
    243c:	34f39a63          	bne	t2,a5,2790 <_ftoa+0x1910>
    2440:	020d0593          	addi	a1,s10,32
    2444:	01010e93          	addi	t4,sp,16
    2448:	001d0b13          	addi	s6,s10,1
    244c:	01d58633          	add	a2,a1,t4
    2450:	400cdc63          	bgez	s9,2868 <_ftoa+0x19e8>
    2454:	02d00513          	li	a0,45
    2458:	fea60023          	sb	a0,-32(a2)
    245c:	016a0c33          	add	s8,s4,s6
    2460:	fffa4893          	not	a7,s4
    2464:	001a0c93          	addi	s9,s4,1
    2468:	01888fb3          	add	t6,a7,s8
    246c:	9de6                	add	s11,s11,s9
    246e:	007ffd13          	andi	s10,t6,7
    2472:	016d8cb3          	add	s9,s11,s6
    2476:	100d0663          	beqz	s10,2582 <_ftoa+0x1702>
    247a:	418c8633          	sub	a2,s9,s8
    247e:	86ca                	mv	a3,s2
    2480:	85a6                	mv	a1,s1
    2482:	9402                	jalr	s0
    2484:	4385                	li	t2,1
    2486:	1c7d                	addi	s8,s8,-1
    2488:	fffc4503          	lbu	a0,-1(s8)
    248c:	0e7d0b63          	beq	s10,t2,2582 <_ftoa+0x1702>
    2490:	4709                	li	a4,2
    2492:	06ed0663          	beq	s10,a4,24fe <_ftoa+0x167e>
    2496:	468d                	li	a3,3
    2498:	04dd0b63          	beq	s10,a3,24ee <_ftoa+0x166e>
    249c:	4e11                	li	t3,4
    249e:	05cd0063          	beq	s10,t3,24de <_ftoa+0x165e>
    24a2:	4f15                	li	t5,5
    24a4:	03ed0563          	beq	s10,t5,24ce <_ftoa+0x164e>
    24a8:	4319                	li	t1,6
    24aa:	006d0a63          	beq	s10,t1,24be <_ftoa+0x163e>
    24ae:	418c8633          	sub	a2,s9,s8
    24b2:	86ca                	mv	a3,s2
    24b4:	85a6                	mv	a1,s1
    24b6:	9402                	jalr	s0
    24b8:	ffec4503          	lbu	a0,-2(s8)
    24bc:	1c7d                	addi	s8,s8,-1
    24be:	418c8633          	sub	a2,s9,s8
    24c2:	86ca                	mv	a3,s2
    24c4:	85a6                	mv	a1,s1
    24c6:	9402                	jalr	s0
    24c8:	ffec4503          	lbu	a0,-2(s8)
    24cc:	1c7d                	addi	s8,s8,-1
    24ce:	418c8633          	sub	a2,s9,s8
    24d2:	86ca                	mv	a3,s2
    24d4:	85a6                	mv	a1,s1
    24d6:	9402                	jalr	s0
    24d8:	ffec4503          	lbu	a0,-2(s8)
    24dc:	1c7d                	addi	s8,s8,-1
    24de:	418c8633          	sub	a2,s9,s8
    24e2:	86ca                	mv	a3,s2
    24e4:	85a6                	mv	a1,s1
    24e6:	9402                	jalr	s0
    24e8:	ffec4503          	lbu	a0,-2(s8)
    24ec:	1c7d                	addi	s8,s8,-1
    24ee:	418c8633          	sub	a2,s9,s8
    24f2:	86ca                	mv	a3,s2
    24f4:	85a6                	mv	a1,s1
    24f6:	9402                	jalr	s0
    24f8:	ffec4503          	lbu	a0,-2(s8)
    24fc:	1c7d                	addi	s8,s8,-1
    24fe:	418c8633          	sub	a2,s9,s8
    2502:	86ca                	mv	a3,s2
    2504:	85a6                	mv	a1,s1
    2506:	9402                	jalr	s0
    2508:	1c7d                	addi	s8,s8,-1
    250a:	fffc4503          	lbu	a0,-1(s8)
    250e:	a895                	j	2582 <_ftoa+0x1702>
    2510:	8de2                	mv	s11,s8
    2512:	89edc50b          	th.lbuib	a0,(s11),-2,0
    2516:	410c8633          	sub	a2,s9,a6
    251a:	86ca                	mv	a3,s2
    251c:	85a6                	mv	a1,s1
    251e:	9402                	jalr	s0
    2520:	8d62                	mv	s10,s8
    2522:	89dd450b          	th.lbuib	a0,(s10),-3,0
    2526:	41bc8633          	sub	a2,s9,s11
    252a:	86ca                	mv	a3,s2
    252c:	85a6                	mv	a1,s1
    252e:	9402                	jalr	s0
    2530:	8de2                	mv	s11,s8
    2532:	89cdc50b          	th.lbuib	a0,(s11),-4,0
    2536:	41ac8633          	sub	a2,s9,s10
    253a:	86ca                	mv	a3,s2
    253c:	85a6                	mv	a1,s1
    253e:	9402                	jalr	s0
    2540:	8d62                	mv	s10,s8
    2542:	89bd450b          	th.lbuib	a0,(s10),-5,0
    2546:	41bc8633          	sub	a2,s9,s11
    254a:	86ca                	mv	a3,s2
    254c:	85a6                	mv	a1,s1
    254e:	9402                	jalr	s0
    2550:	8de2                	mv	s11,s8
    2552:	89adc50b          	th.lbuib	a0,(s11),-6,0
    2556:	41ac8633          	sub	a2,s9,s10
    255a:	86ca                	mv	a3,s2
    255c:	85a6                	mv	a1,s1
    255e:	9402                	jalr	s0
    2560:	8d62                	mv	s10,s8
    2562:	899d450b          	th.lbuib	a0,(s10),-7,0
    2566:	86ca                	mv	a3,s2
    2568:	41bc8633          	sub	a2,s9,s11
    256c:	85a6                	mv	a1,s1
    256e:	9402                	jalr	s0
    2570:	898c450b          	th.lbuib	a0,(s8),-8,0
    2574:	86ca                	mv	a3,s2
    2576:	41ac8633          	sub	a2,s9,s10
    257a:	85a6                	mv	a1,s1
    257c:	9402                	jalr	s0
    257e:	fffc4503          	lbu	a0,-1(s8)
    2582:	86ca                	mv	a3,s2
    2584:	418c8633          	sub	a2,s9,s8
    2588:	85a6                	mv	a1,s1
    258a:	9402                	jalr	s0
    258c:	fffc0813          	addi	a6,s8,-1
    2590:	f90a10e3          	bne	s4,a6,2510 <_ftoa+0x1690>
    2594:	6a22                	ld	s4,8(sp)
    2596:	9b52                	add	s6,s6,s4
    2598:	140b8963          	beqz	s7,26ea <_ftoa+0x186a>
    259c:	413b09b3          	sub	s3,s6,s3
    25a0:	7c0aba8b          	th.extu	s5,s5,31,0
    25a4:	1559f363          	bgeu	s3,s5,26ea <_ftoa+0x186a>
    25a8:	fff9cb93          	not	s7,s3
    25ac:	015b8533          	add	a0,s7,s5
    25b0:	865a                	mv	a2,s6
    25b2:	00757d93          	andi	s11,a0,7
    25b6:	86ca                	mv	a3,s2
    25b8:	85a6                	mv	a1,s1
    25ba:	02000513          	li	a0,32
    25be:	00198d13          	addi	s10,s3,1
    25c2:	0b05                	addi	s6,s6,1
    25c4:	9402                	jalr	s0
    25c6:	135d7263          	bgeu	s10,s5,26ea <_ftoa+0x186a>
    25ca:	080d8e63          	beqz	s11,2666 <_ftoa+0x17e6>
    25ce:	4285                	li	t0,1
    25d0:	085d8163          	beq	s11,t0,2652 <_ftoa+0x17d2>
    25d4:	4789                	li	a5,2
    25d6:	06fd8663          	beq	s11,a5,2642 <_ftoa+0x17c2>
    25da:	458d                	li	a1,3
    25dc:	04bd8b63          	beq	s11,a1,2632 <_ftoa+0x17b2>
    25e0:	4e91                	li	t4,4
    25e2:	05dd8063          	beq	s11,t4,2622 <_ftoa+0x17a2>
    25e6:	4615                	li	a2,5
    25e8:	02cd8563          	beq	s11,a2,2612 <_ftoa+0x1792>
    25ec:	4c99                	li	s9,6
    25ee:	019d8a63          	beq	s11,s9,2602 <_ftoa+0x1782>
    25f2:	865a                	mv	a2,s6
    25f4:	86ca                	mv	a3,s2
    25f6:	85a6                	mv	a1,s1
    25f8:	02000513          	li	a0,32
    25fc:	0b05                	addi	s6,s6,1
    25fe:	9402                	jalr	s0
    2600:	0d05                	addi	s10,s10,1
    2602:	865a                	mv	a2,s6
    2604:	86ca                	mv	a3,s2
    2606:	85a6                	mv	a1,s1
    2608:	02000513          	li	a0,32
    260c:	0b05                	addi	s6,s6,1
    260e:	9402                	jalr	s0
    2610:	0d05                	addi	s10,s10,1
    2612:	865a                	mv	a2,s6
    2614:	86ca                	mv	a3,s2
    2616:	85a6                	mv	a1,s1
    2618:	02000513          	li	a0,32
    261c:	0b05                	addi	s6,s6,1
    261e:	9402                	jalr	s0
    2620:	0d05                	addi	s10,s10,1
    2622:	865a                	mv	a2,s6
    2624:	86ca                	mv	a3,s2
    2626:	85a6                	mv	a1,s1
    2628:	02000513          	li	a0,32
    262c:	0b05                	addi	s6,s6,1
    262e:	9402                	jalr	s0
    2630:	0d05                	addi	s10,s10,1
    2632:	865a                	mv	a2,s6
    2634:	86ca                	mv	a3,s2
    2636:	85a6                	mv	a1,s1
    2638:	02000513          	li	a0,32
    263c:	0b05                	addi	s6,s6,1
    263e:	9402                	jalr	s0
    2640:	0d05                	addi	s10,s10,1
    2642:	865a                	mv	a2,s6
    2644:	86ca                	mv	a3,s2
    2646:	85a6                	mv	a1,s1
    2648:	02000513          	li	a0,32
    264c:	0b05                	addi	s6,s6,1
    264e:	9402                	jalr	s0
    2650:	0d05                	addi	s10,s10,1
    2652:	865a                	mv	a2,s6
    2654:	86ca                	mv	a3,s2
    2656:	85a6                	mv	a1,s1
    2658:	02000513          	li	a0,32
    265c:	0d05                	addi	s10,s10,1
    265e:	0b05                	addi	s6,s6,1
    2660:	9402                	jalr	s0
    2662:	095d7463          	bgeu	s10,s5,26ea <_ftoa+0x186a>
    2666:	865a                	mv	a2,s6
    2668:	86ca                	mv	a3,s2
    266a:	85a6                	mv	a1,s1
    266c:	02000513          	li	a0,32
    2670:	9402                	jalr	s0
    2672:	001b0c13          	addi	s8,s6,1
    2676:	8662                	mv	a2,s8
    2678:	86ca                	mv	a3,s2
    267a:	85a6                	mv	a1,s1
    267c:	02000513          	li	a0,32
    2680:	9402                	jalr	s0
    2682:	002b0993          	addi	s3,s6,2
    2686:	86ca                	mv	a3,s2
    2688:	864e                	mv	a2,s3
    268a:	85a6                	mv	a1,s1
    268c:	02000513          	li	a0,32
    2690:	9402                	jalr	s0
    2692:	003b0a13          	addi	s4,s6,3
    2696:	86ca                	mv	a3,s2
    2698:	8652                	mv	a2,s4
    269a:	85a6                	mv	a1,s1
    269c:	02000513          	li	a0,32
    26a0:	9402                	jalr	s0
    26a2:	004b0b93          	addi	s7,s6,4
    26a6:	86ca                	mv	a3,s2
    26a8:	865e                	mv	a2,s7
    26aa:	85a6                	mv	a1,s1
    26ac:	02000513          	li	a0,32
    26b0:	9402                	jalr	s0
    26b2:	005b0d93          	addi	s11,s6,5
    26b6:	86ca                	mv	a3,s2
    26b8:	866e                	mv	a2,s11
    26ba:	85a6                	mv	a1,s1
    26bc:	02000513          	li	a0,32
    26c0:	9402                	jalr	s0
    26c2:	006b0c93          	addi	s9,s6,6
    26c6:	86ca                	mv	a3,s2
    26c8:	8666                	mv	a2,s9
    26ca:	85a6                	mv	a1,s1
    26cc:	02000513          	li	a0,32
    26d0:	9402                	jalr	s0
    26d2:	007b0c13          	addi	s8,s6,7
    26d6:	86ca                	mv	a3,s2
    26d8:	8662                	mv	a2,s8
    26da:	85a6                	mv	a1,s1
    26dc:	02000513          	li	a0,32
    26e0:	0d21                	addi	s10,s10,8
    26e2:	0b21                	addi	s6,s6,8
    26e4:	9402                	jalr	s0
    26e6:	f95d60e3          	bltu	s10,s5,2666 <_ftoa+0x17e6>
    26ea:	7de2                	ld	s11,56(sp)
    26ec:	6d06                	ld	s10,64(sp)
    26ee:	c95fe06f          	j	1382 <_ftoa+0x502>
    26f2:	002b0633          	add	a2,s6,sp
    26f6:	02e00693          	li	a3,46
    26fa:	001b0f93          	addi	t6,s6,1
    26fe:	00d60823          	sb	a3,16(a2)
    2702:	f7ffe06f          	j	1680 <_ftoa+0x800>
    2706:	0001                	nop
    2708:	004a7813          	andi	a6,s4,4
    270c:	02080e63          	beqz	a6,2748 <_ftoa+0x18c8>
    2710:	002f8f33          	add	t5,t6,sp
    2714:	001f8b13          	addi	s6,t6,1
    2718:	02b00f93          	li	t6,43
    271c:	01ff0823          	sb	t6,16(t5)
    2720:	faaff06f          	j	1eca <_ftoa+0x104a>
    2724:	8d4e                	mv	s10,s3
    2726:	02000b13          	li	s6,32
    272a:	a26ff06f          	j	1950 <_ftoa+0xad0>
    272e:	0001                	nop
    2730:	0f536d63          	bltu	t1,s5,282a <_ftoa+0x19aa>
    2734:	017a7fb3          	and	t6,s4,s7
    2738:	b00f94e3          	bnez	t6,2240 <_ftoa+0x13c0>
    273c:	4b81                	li	s7,0
    273e:	b609                	j	2240 <_ftoa+0x13c0>
    2740:	4585                	li	a1,1
    2742:	0001                	nop
    2744:	00000013          	nop
    2748:	008a7513          	andi	a0,s4,8
    274c:	8b7e                	mv	s6,t6
    274e:	f6050e63          	beqz	a0,1eca <_ftoa+0x104a>
    2752:	002f8cb3          	add	s9,t6,sp
    2756:	02000d13          	li	s10,32
    275a:	001f8b13          	addi	s6,t6,1
    275e:	01ac8823          	sb	s10,16(s9)
    2762:	f68ff06f          	j	1eca <_ftoa+0x104a>
    2766:	0001                	nop
    2768:	0016f893          	andi	a7,a3,1
    276c:	00089463          	bnez	a7,2774 <_ftoa+0x18f4>
    2770:	8c9fe06f          	j	1038 <_ftoa+0x1b8>
    2774:	0685                	addi	a3,a3,1
    2776:	ee7fe06f          	j	165c <_ftoa+0x7dc>
    277a:	0001                	nop
    277c:	417c8633          	sub	a2,s9,s7
    2780:	89fbc50b          	th.lbuib	a0,(s7),-1,0
    2784:	86ca                	mv	a3,s2
    2786:	85a6                	mv	a1,s1
    2788:	9402                	jalr	s0
    278a:	9fcff06f          	j	1986 <_ftoa+0xb06>
    278e:	0001                	nop
    2790:	00e78023          	sb	a4,0(a5)
    2794:	00e780a3          	sb	a4,1(a5)
    2798:	00e78123          	sb	a4,2(a5)
    279c:	00e781a3          	sb	a4,3(a5)
    27a0:	00e78223          	sb	a4,4(a5)
    27a4:	00e782a3          	sb	a4,5(a5)
    27a8:	00e78323          	sb	a4,6(a5)
    27ac:	00e783a3          	sb	a4,7(a5)
    27b0:	07a1                	addi	a5,a5,8
    27b2:	fcf39fe3          	bne	t2,a5,2790 <_ftoa+0x1910>
    27b6:	b169                	j	2440 <_ftoa+0x15c0>
    27b8:	02000b13          	li	s6,32
    27bc:	8d4e                	mv	s10,s3
    27be:	992ff06f          	j	1950 <_ftoa+0xad0>
    27c2:	0001                	nop
    27c4:	02000b13          	li	s6,32
    27c8:	f02ff06f          	j	1eca <_ftoa+0x104a>
    27cc:	22a51e53          	fneg.d	ft8,fa0
    27d0:	fc6e                	sd	s11,56(sp)
    27d2:	e20e06d3          	fmv.x.d	a3,ft8
    27d6:	b225                	j	20fe <_ftoa+0x127e>
    27d8:	02000b13          	li	s6,32
    27dc:	00ca7e93          	andi	t4,s4,12
    27e0:	060e8b63          	beqz	t4,2856 <_ftoa+0x19d6>
    27e4:	3afd                	addiw	s5,s5,-1
    27e6:	7c0abf8b          	th.extu	t6,s5,31,0
    27ea:	87fb6163          	bltu	s6,t6,184c <_ftoa+0x9cc>
    27ee:	02000393          	li	t2,32
    27f2:	947b0e63          	beq	s6,t2,194e <_ftoa+0xace>
    27f6:	004a7813          	andi	a6,s4,4
    27fa:	06080e63          	beqz	a6,2876 <_ftoa+0x19f6>
    27fe:	020b0e13          	addi	t3,s6,32
    2802:	01010f13          	addi	t5,sp,16
    2806:	01ee0fb3          	add	t6,t3,t5
    280a:	02b00313          	li	t1,43
    280e:	fe6f8023          	sb	t1,-32(t6)
    2812:	0b05                	addi	s6,s6,1
    2814:	8d4e                	mv	s10,s3
    2816:	93aff06f          	j	1950 <_ftoa+0xad0>
    281a:	0001                	nop
    281c:	02000d13          	li	s10,32
    2820:	05ab1963          	bne	s6,s10,2872 <_ftoa+0x19f2>
    2824:	02f14503          	lbu	a0,47(sp)
    2828:	b915                	j	245c <_ftoa+0x15dc>
    282a:	002a7293          	andi	t0,s4,2
    282e:	a00299e3          	bnez	t0,2240 <_ftoa+0x13c0>
    2832:	406a87bb          	subw	a5,s5,t1
    2836:	4b81                	li	s7,0
    2838:	b421                	j	2240 <_ftoa+0x13c0>
    283a:	004a7813          	andi	a6,s4,4
    283e:	f00801e3          	beqz	a6,2740 <_ftoa+0x18c0>
    2842:	0b05                	addi	s6,s6,1
    2844:	002f8833          	add	a6,t6,sp
    2848:	02b00713          	li	a4,43
    284c:	00e80823          	sb	a4,16(a6)
    2850:	8d4e                	mv	s10,s3
    2852:	8feff06f          	j	1950 <_ftoa+0xad0>
    2856:	7c0abf8b          	th.extu	t6,s5,31,0
    285a:	01fb7463          	bgeu	s6,t6,2862 <_ftoa+0x19e2>
    285e:	feffe06f          	j	184c <_ftoa+0x9cc>
    2862:	8d4e                	mv	s10,s3
    2864:	8ecff06f          	j	1950 <_ftoa+0xad0>
    2868:	02b00513          	li	a0,43
    286c:	fea60023          	sb	a0,-32(a2)
    2870:	b6f5                	j	245c <_ftoa+0x15dc>
    2872:	8d5a                	mv	s10,s6
    2874:	b6f1                	j	2440 <_ftoa+0x15c0>
    2876:	008a7893          	andi	a7,s4,8
    287a:	8c088a63          	beqz	a7,194e <_ftoa+0xace>
    287e:	8fda                	mv	t6,s6
    2880:	4585                	li	a1,1
    2882:	bdc1                	j	2752 <_ftoa+0x18d2>
    2884:	000a8d63          	beqz	s5,289e <_ftoa+0x1a1e>
    2888:	06080c63          	beqz	a6,2900 <_ftoa+0x1a80>
    288c:	3afd                	addiw	s5,s5,-1
    288e:	7c0ab68b          	th.extu	a3,s5,31,0
    2892:	04dff463          	bgeu	t6,a3,28da <_ftoa+0x1a5a>
    2896:	8b7e                	mv	s6,t6
    2898:	8fb6                	mv	t6,a3
    289a:	fb3fe06f          	j	184c <_ftoa+0x9cc>
    289e:	02000b93          	li	s7,32
    28a2:	037f8863          	beq	t6,s7,28d2 <_ftoa+0x1a52>
    28a6:	00080f63          	beqz	a6,28c4 <_ftoa+0x1a44>
    28aa:	017f8d33          	add	s10,t6,s7
    28ae:	002d05b3          	add	a1,s10,sp
    28b2:	02d00793          	li	a5,45
    28b6:	001f8b13          	addi	s6,t6,1
    28ba:	fef58823          	sb	a5,-16(a1)
    28be:	8d4e                	mv	s10,s3
    28c0:	890ff06f          	j	1950 <_ftoa+0xad0>
    28c4:	004a7c93          	andi	s9,s4,4
    28c8:	001f8b13          	addi	s6,t6,1
    28cc:	f60c9ce3          	bnez	s9,2844 <_ftoa+0x19c4>
    28d0:	bda5                	j	2748 <_ftoa+0x18c8>
    28d2:	8b7e                	mv	s6,t6
    28d4:	8d4e                	mv	s10,s3
    28d6:	87aff06f          	j	1950 <_ftoa+0xad0>
    28da:	02000713          	li	a4,32
    28de:	feef8ae3          	beq	t6,a4,28d2 <_ftoa+0x1a52>
    28e2:	00ef8533          	add	a0,t6,a4
    28e6:	01010b93          	addi	s7,sp,16
    28ea:	02d00d13          	li	s10,45
    28ee:	01750cb3          	add	s9,a0,s7
    28f2:	ffac8023          	sb	s10,-32(s9)
    28f6:	01df8b33          	add	s6,t6,t4
    28fa:	8d4e                	mv	s10,s3
    28fc:	854ff06f          	j	1950 <_ftoa+0xad0>
    2900:	8b7e                	mv	s6,t6
    2902:	bde9                	j	27dc <_ftoa+0x195c>
    2904:	00000013          	nop
    2908:	00000013          	nop
    290c:	00000013          	nop

0000000000002910 <_vsnprintf>:
    2910:	7131                	addi	sp,sp,-192
    2912:	f526                	sd	s1,168(sp)
    2914:	f922                	sd	s0,176(sp)
    2916:	6405                	lui	s0,0x1
    2918:	ed4e                	sd	s3,152(sp)
    291a:	f14a                	sd	s2,160(sp)
    291c:	fd06                	sd	ra,184(sp)
    291e:	e5040413          	addi	s0,s0,-432 # e50 <_out_null>
    2922:	42b5140b          	th.mvnez	s0,a0,a1
    2926:	0006c503          	lbu	a0,0(a3)
    292a:	4381                	li	t2,0
    292c:	892e                	mv	s2,a1
    292e:	84b2                	mv	s1,a2
    2930:	e119                	bnez	a0,2936 <_vsnprintf+0x26>
    2932:	3550106f          	j	4486 <_vsnprintf+0x1b76>
    2936:	67a9                	lui	a5,0xa
    2938:	54478293          	addi	t0,a5,1348 # a544 <__errno+0x298>
    293c:	e556                	sd	s5,136(sp)
    293e:	e952                	sd	s4,144(sp)
    2940:	6a29                	lui	s4,0xa
    2942:	ecee                	sd	s11,88(sp)
    2944:	f0ea                	sd	s10,96(sp)
    2946:	f4e6                	sd	s9,104(sp)
    2948:	f8e2                	sd	s8,112(sp)
    294a:	fcde                	sd	s7,120(sp)
    294c:	e15a                	sd	s6,128(sp)
    294e:	49c1                	li	s3,16
    2950:	e01e                	sd	t2,0(sp)
    2952:	e816                	sd	t0,16(sp)
    2954:	8cb6                	mv	s9,a3
    2956:	8dba                	mv	s11,a4
    2958:	500a0a13          	addi	s4,s4,1280 # a500 <__errno+0x254>
    295c:	a831                	j	2978 <_vsnprintf+0x68>
    295e:	0001                	nop
    2960:	6602                	ld	a2,0(sp)
    2962:	86a6                	mv	a3,s1
    2964:	85ca                	mv	a1,s2
    2966:	00160c13          	addi	s8,a2,1
    296a:	0c85                	addi	s9,s9,1
    296c:	9402                	jalr	s0
    296e:	e062                	sd	s8,0(sp)
    2970:	000cc503          	lbu	a0,0(s9)
    2974:	1c050263          	beqz	a0,2b38 <_vsnprintf+0x228>
    2978:	02500313          	li	t1,37
    297c:	fe6512e3          	bne	a0,t1,2960 <_vsnprintf+0x50>
    2980:	002c8893          	addi	a7,s9,2
    2984:	4b01                	li	s6,0
    2986:	0001                	nop
    2988:	fff8c503          	lbu	a0,-1(a7)
    298c:	fe05071b          	addiw	a4,a0,-32
    2990:	0ff77393          	zext.b	t2,a4
    2994:	0079e663          	bltu	s3,t2,29a0 <_vsnprintf+0x90>
    2998:	447a458b          	th.lrw	a1,s4,t2,2
    299c:	8582                	jr	a1
    299e:	0001                	nop
    29a0:	fff88a93          	addi	s5,a7,-1
    29a4:	fd050c1b          	addiw	s8,a0,-48
    29a8:	4ba5                	li	s7,9
    29aa:	e456                	sd	s5,8(sp)
    29ac:	0ffc7c93          	zext.b	s9,s8
    29b0:	0b9bf663          	bgeu	s7,s9,2a5c <_vsnprintf+0x14c>
    29b4:	02a00d13          	li	s10,42
    29b8:	4881                	li	a7,0
    29ba:	35a50163          	beq	a0,s10,2cfc <_vsnprintf+0x3ec>
    29be:	02e00f93          	li	t6,46
    29c2:	4c01                	li	s8,0
    29c4:	15f50363          	beq	a0,t6,2b0a <_vsnprintf+0x1fa>
    29c8:	f985081b          	addiw	a6,a0,-104
    29cc:	0ff87f93          	zext.b	t6,a6
    29d0:	4ac9                	li	s5,18
    29d2:	05faef63          	bltu	s5,t6,2a30 <_vsnprintf+0x120>
    29d6:	6bc2                	ld	s7,16(sp)
    29d8:	45fbcc8b          	th.lrw	s9,s7,t6,2
    29dc:	8c82                	jr	s9
    29de:	0001                	nop
    29e0:	001b6b13          	ori	s6,s6,1
    29e4:	2b01                	sext.w	s6,s6
    29e6:	0885                	addi	a7,a7,1
    29e8:	b745                	j	2988 <_vsnprintf+0x78>
    29ea:	0001                	nop
    29ec:	002b6513          	ori	a0,s6,2
    29f0:	00050b1b          	sext.w	s6,a0
    29f4:	0885                	addi	a7,a7,1
    29f6:	bf49                	j	2988 <_vsnprintf+0x78>
    29f8:	004b6613          	ori	a2,s6,4
    29fc:	00060b1b          	sext.w	s6,a2
    2a00:	0885                	addi	a7,a7,1
    2a02:	b759                	j	2988 <_vsnprintf+0x78>
    2a04:	010b6693          	ori	a3,s6,16
    2a08:	00068b1b          	sext.w	s6,a3
    2a0c:	0885                	addi	a7,a7,1
    2a0e:	bfad                	j	2988 <_vsnprintf+0x78>
    2a10:	008b6813          	ori	a6,s6,8
    2a14:	00080b1b          	sext.w	s6,a6
    2a18:	0885                	addi	a7,a7,1
    2a1a:	b7bd                	j	2988 <_vsnprintf+0x78>
    2a1c:	6322                	ld	t1,8(sp)
    2a1e:	100b6693          	ori	a3,s6,256
    2a22:	00068b1b          	sext.w	s6,a3
    2a26:	00134503          	lbu	a0,1(t1)
    2a2a:	00130393          	addi	t2,t1,1
    2a2e:	e41e                	sd	t2,8(sp)
    2a30:	06700a93          	li	s5,103
    2a34:	14aae063          	bltu	s5,a0,2b74 <_vsnprintf+0x264>
    2a38:	02400d13          	li	s10,36
    2a3c:	2cad7c63          	bgeu	s10,a0,2d14 <_vsnprintf+0x404>
    2a40:	fdb50c9b          	addiw	s9,a0,-37
    2a44:	0ffcf693          	zext.b	a3,s9
    2a48:	04200393          	li	t2,66
    2a4c:	2cd3e463          	bltu	t2,a3,2d14 <_vsnprintf+0x404>
    2a50:	6329                	lui	t1,0xa
    2a52:	59030813          	addi	a6,t1,1424 # a590 <__errno+0x2e4>
    2a56:	44d84f8b          	th.lrw	t6,a6,a3,2
    2a5a:	8f82                	jr	t6
    2a5c:	66a2                	ld	a3,8(sp)
    2a5e:	4881                	li	a7,0
    2a60:	8fde                	mv	t6,s7
    2a62:	0028929b          	slliw	t0,a7,0x2
    2a66:	0112833b          	addw	t1,t0,a7
    2a6a:	0685                	addi	a3,a3,1
    2a6c:	0013171b          	slliw	a4,t1,0x1
    2a70:	00a703bb          	addw	t2,a4,a0
    2a74:	0006c503          	lbu	a0,0(a3)
    2a78:	87b6                	mv	a5,a3
    2a7a:	fd03889b          	addiw	a7,t2,-48
    2a7e:	fd05059b          	addiw	a1,a0,-48
    2a82:	0ff5f613          	zext.b	a2,a1
    2a86:	06cfec63          	bltu	t6,a2,2afe <_vsnprintf+0x1ee>
    2a8a:	0028981b          	slliw	a6,a7,0x2
    2a8e:	011808bb          	addw	a7,a6,a7
    2a92:	00189a9b          	slliw	s5,a7,0x1
    2a96:	00aa853b          	addw	a0,s5,a0
    2a9a:	fd05089b          	addiw	a7,a0,-48
    2a9e:	8816c50b          	th.lbuib	a0,(a3),1,0
    2aa2:	fd050b9b          	addiw	s7,a0,-48
    2aa6:	0ffbfc13          	zext.b	s8,s7
    2aaa:	058fea63          	bltu	t6,s8,2afe <_vsnprintf+0x1ee>
    2aae:	00289c9b          	slliw	s9,a7,0x2
    2ab2:	011c8d3b          	addw	s10,s9,a7
    2ab6:	001d1e1b          	slliw	t3,s10,0x1
    2aba:	00ae0ebb          	addw	t4,t3,a0
    2abe:	0027c503          	lbu	a0,2(a5)
    2ac2:	00278693          	addi	a3,a5,2
    2ac6:	fd0e889b          	addiw	a7,t4,-48
    2aca:	fd050f1b          	addiw	t5,a0,-48
    2ace:	0fff7293          	zext.b	t0,t5
    2ad2:	025fe663          	bltu	t6,t0,2afe <_vsnprintf+0x1ee>
    2ad6:	0028931b          	slliw	t1,a7,0x2
    2ada:	0113073b          	addw	a4,t1,a7
    2ade:	0017139b          	slliw	t2,a4,0x1
    2ae2:	00a385bb          	addw	a1,t2,a0
    2ae6:	0037c503          	lbu	a0,3(a5)
    2aea:	00378693          	addi	a3,a5,3
    2aee:	fd05889b          	addiw	a7,a1,-48
    2af2:	fd05079b          	addiw	a5,a0,-48
    2af6:	0ff7f613          	zext.b	a2,a5
    2afa:	f6cff4e3          	bgeu	t6,a2,2a62 <_vsnprintf+0x152>
    2afe:	e436                	sd	a3,8(sp)
    2b00:	02e00f93          	li	t6,46
    2b04:	4c01                	li	s8,0
    2b06:	edf511e3          	bne	a0,t6,29c8 <_vsnprintf+0xb8>
    2b0a:	6aa2                	ld	s5,8(sp)
    2b0c:	400b6b13          	ori	s6,s6,1024
    2b10:	4825                	li	a6,9
    2b12:	001ac503          	lbu	a0,1(s5)
    2b16:	2b01                	sext.w	s6,s6
    2b18:	001a8713          	addi	a4,s5,1
    2b1c:	fd050b9b          	addiw	s7,a0,-48
    2b20:	0ffbfc93          	zext.b	s9,s7
    2b24:	21987463          	bgeu	a6,s9,2d2c <_vsnprintf+0x41c>
    2b28:	02a00d13          	li	s10,42
    2b2c:	01a51463          	bne	a0,s10,2b34 <_vsnprintf+0x224>
    2b30:	7c70006f          	j	3af6 <_vsnprintf+0x11e6>
    2b34:	e43a                	sd	a4,8(sp)
    2b36:	bd49                	j	29c8 <_vsnprintf+0xb8>
    2b38:	6382                	ld	t2,0(sp)
    2b3a:	6de6                	ld	s11,88(sp)
    2b3c:	7d06                	ld	s10,96(sp)
    2b3e:	7ca6                	ld	s9,104(sp)
    2b40:	7c46                	ld	s8,112(sp)
    2b42:	7be6                	ld	s7,120(sp)
    2b44:	6b0a                	ld	s6,128(sp)
    2b46:	6aaa                	ld	s5,136(sp)
    2b48:	6a4a                	ld	s4,144(sp)
    2b4a:	0003899b          	sext.w	s3,t2
    2b4e:	0093b7b3          	sltu	a5,t2,s1
    2b52:	fff48613          	addi	a2,s1,-1
    2b56:	86a6                	mv	a3,s1
    2b58:	85ca                	mv	a1,s2
    2b5a:	4501                	li	a0,0
    2b5c:	42f3960b          	th.mvnez	a2,t2,a5
    2b60:	9402                	jalr	s0
    2b62:	70ea                	ld	ra,184(sp)
    2b64:	74aa                	ld	s1,168(sp)
    2b66:	744a                	ld	s0,176(sp)
    2b68:	854e                	mv	a0,s3
    2b6a:	69ea                	ld	s3,152(sp)
    2b6c:	790a                	ld	s2,160(sp)
    2b6e:	6129                	addi	sp,sp,192
    2b70:	8082                	ret
    2b72:	0001                	nop
    2b74:	f9750b9b          	addiw	s7,a0,-105
    2b78:	0ffbfc93          	zext.b	s9,s7
    2b7c:	4d3d                	li	s10,15
    2b7e:	199d6b63          	bltu	s10,s9,2d14 <_vsnprintf+0x404>
    2b82:	4e05                	li	t3,1
    2b84:	62a5                	lui	t0,0x9
    2b86:	019e1eb3          	sll	t4,t3,s9
    2b8a:	04128693          	addi	a3,t0,65 # 9041 <ck_uart_set_wordsize+0x71>
    2b8e:	00def7b3          	and	a5,t4,a3
    2b92:	72079de3          	bnez	a5,3acc <_vsnprintf+0x11bc>
    2b96:	4fa9                	li	t6,10
    2b98:	23fc8a63          	beq	s9,t6,2dcc <_vsnprintf+0x4bc>
    2b9c:	439d                	li	t2,7
    2b9e:	167c9b63          	bne	s9,t2,2d14 <_vsnprintf+0x404>
    2ba2:	788dc28b          	th.ldia	t0,(s11),8,0
    2ba6:	760288e3          	beqz	t0,3b16 <_vsnprintf+0x1206>
    2baa:	021b6f13          	ori	t5,s6,33
    2bae:	000f059b          	sext.w	a1,t5
    2bb2:	400b7c93          	andi	s9,s6,1024
    2bb6:	010b7b93          	andi	s7,s6,16
    2bba:	453d                	li	a0,15
    2bbc:	00a2f333          	and	t1,t0,a0
    2bc0:	43a5                	li	t2,9
    2bc2:	03030d13          	addi	s10,t1,48
    2bc6:	03730f13          	addi	t5,t1,55
    2bca:	0063b633          	sltu	a2,t2,t1
    2bce:	40cd1f0b          	th.mveqz	t5,s10,a2
    2bd2:	03e10823          	sb	t5,48(sp)
    2bd6:	03010b13          	addi	s6,sp,48
    2bda:	02000893          	li	a7,32
    2bde:	4d05                	li	s10,1
    2be0:	0042d813          	srli	a6,t0,0x4
    2be4:	00556463          	bltu	a0,t0,2bec <_vsnprintf+0x2dc>
    2be8:	6180106f          	j	4200 <_vsnprintf+0x18f0>
    2bec:	00f87f93          	andi	t6,a6,15
    2bf0:	030f8a93          	addi	s5,t6,48
    2bf4:	037f8e93          	addi	t4,t6,55
    2bf8:	01f3b2b3          	sltu	t0,t2,t6
    2bfc:	405a9e8b          	th.mveqz	t4,s5,t0
    2c00:	03d108a3          	sb	t4,49(sp)
    2c04:	87ea                	mv	a5,s10
    2c06:	00485313          	srli	t1,a6,0x4
    2c0a:	4d09                	li	s10,2
    2c0c:	01056463          	bltu	a0,a6,2c14 <_vsnprintf+0x304>
    2c10:	5f00106f          	j	4200 <_vsnprintf+0x18f0>
    2c14:	00f37f13          	andi	t5,t1,15
    2c18:	030f0813          	addi	a6,t5,48
    2c1c:	037f0713          	addi	a4,t5,55
    2c20:	01e3bfb3          	sltu	t6,t2,t5
    2c24:	41f8170b          	th.mveqz	a4,a6,t6
    2c28:	02e10923          	sb	a4,50(sp)
    2c2c:	87ea                	mv	a5,s10
    2c2e:	00435e13          	srli	t3,t1,0x4
    2c32:	0d05                	addi	s10,s10,1
    2c34:	00656463          	bltu	a0,t1,2c3c <_vsnprintf+0x32c>
    2c38:	5c80106f          	j	4200 <_vsnprintf+0x18f0>
    2c3c:	03310613          	addi	a2,sp,51
    2c40:	87ea                	mv	a5,s10
    2c42:	8772                	mv	a4,t3
    2c44:	00000013          	nop
    2c48:	00f77d13          	andi	s10,a4,15
    2c4c:	030d0e93          	addi	t4,s10,48
    2c50:	037d0293          	addi	t0,s10,55
    2c54:	01a3b333          	sltu	t1,t2,s10
    2c58:	406e928b          	th.mveqz	t0,t4,t1
    2c5c:	00560023          	sb	t0,0(a2)
    2c60:	00178d13          	addi	s10,a5,1
    2c64:	00475f13          	srli	t5,a4,0x4
    2c68:	00e56463          	bltu	a0,a4,2c70 <_vsnprintf+0x360>
    2c6c:	5940106f          	j	4200 <_vsnprintf+0x18f0>
    2c70:	011d1463          	bne	s10,a7,2c78 <_vsnprintf+0x368>
    2c74:	1750106f          	j	45e8 <_vsnprintf+0x1cd8>
    2c78:	00ff7f93          	andi	t6,t5,15
    2c7c:	886a                	mv	a6,s10
    2c7e:	87ea                	mv	a5,s10
    2c80:	030f8e13          	addi	t3,t6,48
    2c84:	01f3bd33          	sltu	s10,t2,t6
    2c88:	037f8a93          	addi	s5,t6,55
    2c8c:	41ae1a8b          	th.mveqz	s5,t3,s10
    2c90:	015600a3          	sb	s5,1(a2)
    2c94:	00180d13          	addi	s10,a6,1
    2c98:	00875e93          	srli	t4,a4,0x8
    2c9c:	01e56463          	bltu	a0,t5,2ca4 <_vsnprintf+0x394>
    2ca0:	5600106f          	j	4200 <_vsnprintf+0x18f0>
    2ca4:	00fef313          	andi	t1,t4,15
    2ca8:	03030293          	addi	t0,t1,48
    2cac:	03730f93          	addi	t6,t1,55
    2cb0:	0063b6b3          	sltu	a3,t2,t1
    2cb4:	40d29f8b          	th.mveqz	t6,t0,a3
    2cb8:	01f60123          	sb	t6,2(a2)
    2cbc:	87ea                	mv	a5,s10
    2cbe:	00c75e13          	srli	t3,a4,0xc
    2cc2:	0d05                	addi	s10,s10,1
    2cc4:	01d56463          	bltu	a0,t4,2ccc <_vsnprintf+0x3bc>
    2cc8:	5380106f          	j	4200 <_vsnprintf+0x18f0>
    2ccc:	00fe7a93          	andi	s5,t3,15
    2cd0:	030a8e93          	addi	t4,s5,48
    2cd4:	037a8313          	addi	t1,s5,55
    2cd8:	0153bf33          	sltu	t5,t2,s5
    2cdc:	41ee930b          	th.mveqz	t1,t4,t5
    2ce0:	006601a3          	sb	t1,3(a2)
    2ce4:	00280793          	addi	a5,a6,2
    2ce8:	00380d13          	addi	s10,a6,3
    2cec:	8341                	srli	a4,a4,0x10
    2cee:	01c56463          	bltu	a0,t3,2cf6 <_vsnprintf+0x3e6>
    2cf2:	50e0106f          	j	4200 <_vsnprintf+0x18f0>
    2cf6:	0611                	addi	a2,a2,4
    2cf8:	87ea                	mv	a5,s10
    2cfa:	b7b9                	j	2c48 <_vsnprintf+0x338>
    2cfc:	588dc88b          	th.lwia	a7,(s11),8,0
    2d00:	4e08c463          	bltz	a7,31e8 <_vsnprintf+0x8d8>
    2d04:	6ea2                	ld	t4,8(sp)
    2d06:	001e8f13          	addi	t5,t4,1
    2d0a:	001ec503          	lbu	a0,1(t4)
    2d0e:	e47a                	sd	t5,8(sp)
    2d10:	b17d                	j	29be <_vsnprintf+0xae>
    2d12:	0001                	nop
    2d14:	6602                	ld	a2,0(sp)
    2d16:	86a6                	mv	a3,s1
    2d18:	85ca                	mv	a1,s2
    2d1a:	00160d13          	addi	s10,a2,1
    2d1e:	9402                	jalr	s0
    2d20:	6fa2                	ld	t6,8(sp)
    2d22:	e06a                	sd	s10,0(sp)
    2d24:	001f8c93          	addi	s9,t6,1
    2d28:	b1a1                	j	2970 <_vsnprintf+0x60>
    2d2a:	0001                	nop
    2d2c:	002c129b          	slliw	t0,s8,0x2
    2d30:	018286bb          	addw	a3,t0,s8
    2d34:	0705                	addi	a4,a4,1
    2d36:	0016931b          	slliw	t1,a3,0x1
    2d3a:	00a303bb          	addw	t2,t1,a0
    2d3e:	00074503          	lbu	a0,0(a4)
    2d42:	8f3a                	mv	t5,a4
    2d44:	fd038c1b          	addiw	s8,t2,-48
    2d48:	fd05059b          	addiw	a1,a0,-48
    2d4c:	0ff5f793          	zext.b	a5,a1
    2d50:	def862e3          	bltu	a6,a5,2b34 <_vsnprintf+0x224>
    2d54:	002c161b          	slliw	a2,s8,0x2
    2d58:	01860fbb          	addw	t6,a2,s8
    2d5c:	001f9a9b          	slliw	s5,t6,0x1
    2d60:	00aa8bbb          	addw	s7,s5,a0
    2d64:	8817450b          	th.lbuib	a0,(a4),1,0
    2d68:	fd0b8c1b          	addiw	s8,s7,-48
    2d6c:	fd050c9b          	addiw	s9,a0,-48
    2d70:	0ffcfd13          	zext.b	s10,s9
    2d74:	dda860e3          	bltu	a6,s10,2b34 <_vsnprintf+0x224>
    2d78:	002c1e1b          	slliw	t3,s8,0x2
    2d7c:	018e0c3b          	addw	s8,t3,s8
    2d80:	001c1e9b          	slliw	t4,s8,0x1
    2d84:	00ae853b          	addw	a0,t4,a0
    2d88:	fd050c1b          	addiw	s8,a0,-48
    2d8c:	002f4503          	lbu	a0,2(t5)
    2d90:	002f0713          	addi	a4,t5,2
    2d94:	fd05029b          	addiw	t0,a0,-48
    2d98:	0ff2f693          	zext.b	a3,t0
    2d9c:	d8d86ce3          	bltu	a6,a3,2b34 <_vsnprintf+0x224>
    2da0:	002c131b          	slliw	t1,s8,0x2
    2da4:	018303bb          	addw	t2,t1,s8
    2da8:	0013959b          	slliw	a1,t2,0x1
    2dac:	00a587bb          	addw	a5,a1,a0
    2db0:	003f4503          	lbu	a0,3(t5)
    2db4:	003f0713          	addi	a4,t5,3
    2db8:	fd078c1b          	addiw	s8,a5,-48
    2dbc:	fd050f1b          	addiw	t5,a0,-48
    2dc0:	0fff7613          	zext.b	a2,t5
    2dc4:	f6c874e3          	bgeu	a6,a2,2d2c <_vsnprintf+0x41c>
    2dc8:	e43a                	sd	a4,8(sp)
    2dca:	befd                	j	29c8 <_vsnprintf+0xb8>
    2dcc:	788dcd0b          	th.ldia	s10,(s11),8,0
    2dd0:	7c0c3a8b          	th.extu	s5,s8,31,0
    2dd4:	5bfd                	li	s7,-1
    2dd6:	000d4503          	lbu	a0,0(s10)
    2dda:	418b9a8b          	th.mveqz	s5,s7,s8
    2dde:	015d0cb3          	add	s9,s10,s5
    2de2:	87ea                	mv	a5,s10
    2de4:	e119                	bnez	a0,2dea <_vsnprintf+0x4da>
    2de6:	2650206f          	j	584a <_vsnprintf+0x2f3a>
    2dea:	41ac8eb3          	sub	t4,s9,s10
    2dee:	007ef293          	andi	t0,t4,7
    2df2:	04028e63          	beqz	t0,2e4e <_vsnprintf+0x53e>
    2df6:	001d4683          	lbu	a3,1(s10)
    2dfa:	001d0793          	addi	a5,s10,1
    2dfe:	c6d5                	beqz	a3,2eaa <_vsnprintf+0x59a>
    2e00:	05c28763          	beq	t0,t3,2e4e <_vsnprintf+0x53e>
    2e04:	4309                	li	t1,2
    2e06:	04628063          	beq	t0,t1,2e46 <_vsnprintf+0x536>
    2e0a:	438d                	li	t2,3
    2e0c:	02728963          	beq	t0,t2,2e3e <_vsnprintf+0x52e>
    2e10:	4f11                	li	t5,4
    2e12:	03e28263          	beq	t0,t5,2e36 <_vsnprintf+0x526>
    2e16:	4595                	li	a1,5
    2e18:	00b28b63          	beq	t0,a1,2e2e <_vsnprintf+0x51e>
    2e1c:	4619                	li	a2,6
    2e1e:	00c28463          	beq	t0,a2,2e26 <_vsnprintf+0x516>
    2e22:	7a90106f          	j	4dca <_vsnprintf+0x24ba>
    2e26:	8817c80b          	th.lbuib	a6,(a5),1,0
    2e2a:	08080063          	beqz	a6,2eaa <_vsnprintf+0x59a>
    2e2e:	8817cf8b          	th.lbuib	t6,(a5),1,0
    2e32:	060f8c63          	beqz	t6,2eaa <_vsnprintf+0x59a>
    2e36:	8817ca8b          	th.lbuib	s5,(a5),1,0
    2e3a:	060a8863          	beqz	s5,2eaa <_vsnprintf+0x59a>
    2e3e:	8817cb8b          	th.lbuib	s7,(a5),1,0
    2e42:	060b8463          	beqz	s7,2eaa <_vsnprintf+0x59a>
    2e46:	8817ce0b          	th.lbuib	t3,(a5),1,0
    2e4a:	060e0063          	beqz	t3,2eaa <_vsnprintf+0x59a>
    2e4e:	00fc9463          	bne	s9,a5,2e56 <_vsnprintf+0x546>
    2e52:	5480106f          	j	439a <_vsnprintf+0x1a8a>
    2e56:	0017c283          	lbu	t0,1(a5)
    2e5a:	0785                	addi	a5,a5,1
    2e5c:	8ebe                	mv	t4,a5
    2e5e:	04028663          	beqz	t0,2eaa <_vsnprintf+0x59a>
    2e62:	8817c68b          	th.lbuib	a3,(a5),1,0
    2e66:	c2b1                	beqz	a3,2eaa <_vsnprintf+0x59a>
    2e68:	002ec303          	lbu	t1,2(t4)
    2e6c:	002e8793          	addi	a5,t4,2
    2e70:	02030d63          	beqz	t1,2eaa <_vsnprintf+0x59a>
    2e74:	003ec383          	lbu	t2,3(t4)
    2e78:	003e8793          	addi	a5,t4,3
    2e7c:	02038763          	beqz	t2,2eaa <_vsnprintf+0x59a>
    2e80:	004ecf03          	lbu	t5,4(t4)
    2e84:	004e8793          	addi	a5,t4,4
    2e88:	020f0163          	beqz	t5,2eaa <_vsnprintf+0x59a>
    2e8c:	005ec583          	lbu	a1,5(t4)
    2e90:	005e8793          	addi	a5,t4,5
    2e94:	c999                	beqz	a1,2eaa <_vsnprintf+0x59a>
    2e96:	006ec603          	lbu	a2,6(t4)
    2e9a:	006e8793          	addi	a5,t4,6
    2e9e:	c611                	beqz	a2,2eaa <_vsnprintf+0x59a>
    2ea0:	007ec703          	lbu	a4,7(t4)
    2ea4:	007e8793          	addi	a5,t4,7
    2ea8:	f35d                	bnez	a4,2e4e <_vsnprintf+0x53e>
    2eaa:	400b7c93          	andi	s9,s6,1024
    2eae:	41a78bbb          	subw	s7,a5,s10
    2eb2:	000c9463          	bnez	s9,2eba <_vsnprintf+0x5aa>
    2eb6:	4f20106f          	j	43a8 <_vsnprintf+0x1a98>
    2eba:	018bb833          	sltu	a6,s7,s8
    2ebe:	002b7f93          	andi	t6,s6,2
    2ec2:	410c1b8b          	th.mveqz	s7,s8,a6
    2ec6:	000f9463          	bnez	t6,2ece <_vsnprintf+0x5be>
    2eca:	7e00206f          	j	56aa <_vsnprintf+0x2d9a>
    2ece:	6c82                	ld	s9,0(sp)
    2ed0:	4a89                	li	s5,2
    2ed2:	7c0c360b          	th.extu	a2,s8,31,0
    2ed6:	01960733          	add	a4,a2,s9
    2eda:	41970833          	sub	a6,a4,s9
    2ede:	00787f93          	andi	t6,a6,7
    2ee2:	e03a                	sd	a4,0(sp)
    2ee4:	8c66                	mv	s8,s9
    2ee6:	419d0b33          	sub	s6,s10,s9
    2eea:	0e0f8163          	beqz	t6,2fcc <_vsnprintf+0x6bc>
    2eee:	ec46                	sd	a7,24(sp)
    2ef0:	f07e                	sd	t6,32(sp)
    2ef2:	86a6                	mv	a3,s1
    2ef4:	8666                	mv	a2,s9
    2ef6:	85ca                	mv	a1,s2
    2ef8:	9402                	jalr	s0
    2efa:	001c8d13          	addi	s10,s9,1
    2efe:	81ab450b          	th.lrbu	a0,s6,s10,0
    2f02:	68e2                	ld	a7,24(sp)
    2f04:	e119                	bnez	a0,2f0a <_vsnprintf+0x5fa>
    2f06:	2f00106f          	j	41f6 <_vsnprintf+0x18e6>
    2f0a:	7e82                	ld	t4,32(sp)
    2f0c:	4e05                	li	t3,1
    2f0e:	8c6a                	mv	s8,s10
    2f10:	0bce8e63          	beq	t4,t3,2fcc <_vsnprintf+0x6bc>
    2f14:	4289                	li	t0,2
    2f16:	085e8e63          	beq	t4,t0,2fb2 <_vsnprintf+0x6a2>
    2f1a:	468d                	li	a3,3
    2f1c:	06de8e63          	beq	t4,a3,2f98 <_vsnprintf+0x688>
    2f20:	4311                	li	t1,4
    2f22:	046e8e63          	beq	t4,t1,2f7e <_vsnprintf+0x66e>
    2f26:	4395                	li	t2,5
    2f28:	027e8e63          	beq	t4,t2,2f64 <_vsnprintf+0x654>
    2f2c:	4f19                	li	t5,6
    2f2e:	01ee8e63          	beq	t4,t5,2f4a <_vsnprintf+0x63a>
    2f32:	8662                	mv	a2,s8
    2f34:	86a6                	mv	a3,s1
    2f36:	85ca                	mv	a1,s2
    2f38:	0d05                	addi	s10,s10,1
    2f3a:	9402                	jalr	s0
    2f3c:	81ab450b          	th.lrbu	a0,s6,s10,0
    2f40:	68e2                	ld	a7,24(sp)
    2f42:	8c6a                	mv	s8,s10
    2f44:	e119                	bnez	a0,2f4a <_vsnprintf+0x63a>
    2f46:	2b00106f          	j	41f6 <_vsnprintf+0x18e6>
    2f4a:	8662                	mv	a2,s8
    2f4c:	ec46                	sd	a7,24(sp)
    2f4e:	86a6                	mv	a3,s1
    2f50:	85ca                	mv	a1,s2
    2f52:	0d05                	addi	s10,s10,1
    2f54:	9402                	jalr	s0
    2f56:	81ab450b          	th.lrbu	a0,s6,s10,0
    2f5a:	68e2                	ld	a7,24(sp)
    2f5c:	8c6a                	mv	s8,s10
    2f5e:	e119                	bnez	a0,2f64 <_vsnprintf+0x654>
    2f60:	2960106f          	j	41f6 <_vsnprintf+0x18e6>
    2f64:	8662                	mv	a2,s8
    2f66:	ec46                	sd	a7,24(sp)
    2f68:	86a6                	mv	a3,s1
    2f6a:	85ca                	mv	a1,s2
    2f6c:	0d05                	addi	s10,s10,1
    2f6e:	9402                	jalr	s0
    2f70:	81ab450b          	th.lrbu	a0,s6,s10,0
    2f74:	68e2                	ld	a7,24(sp)
    2f76:	8c6a                	mv	s8,s10
    2f78:	e119                	bnez	a0,2f7e <_vsnprintf+0x66e>
    2f7a:	27c0106f          	j	41f6 <_vsnprintf+0x18e6>
    2f7e:	8662                	mv	a2,s8
    2f80:	ec46                	sd	a7,24(sp)
    2f82:	86a6                	mv	a3,s1
    2f84:	85ca                	mv	a1,s2
    2f86:	0d05                	addi	s10,s10,1
    2f88:	9402                	jalr	s0
    2f8a:	81ab450b          	th.lrbu	a0,s6,s10,0
    2f8e:	68e2                	ld	a7,24(sp)
    2f90:	8c6a                	mv	s8,s10
    2f92:	e119                	bnez	a0,2f98 <_vsnprintf+0x688>
    2f94:	2620106f          	j	41f6 <_vsnprintf+0x18e6>
    2f98:	8662                	mv	a2,s8
    2f9a:	ec46                	sd	a7,24(sp)
    2f9c:	86a6                	mv	a3,s1
    2f9e:	85ca                	mv	a1,s2
    2fa0:	0d05                	addi	s10,s10,1
    2fa2:	9402                	jalr	s0
    2fa4:	81ab450b          	th.lrbu	a0,s6,s10,0
    2fa8:	68e2                	ld	a7,24(sp)
    2faa:	8c6a                	mv	s8,s10
    2fac:	e119                	bnez	a0,2fb2 <_vsnprintf+0x6a2>
    2fae:	2480106f          	j	41f6 <_vsnprintf+0x18e6>
    2fb2:	8662                	mv	a2,s8
    2fb4:	ec46                	sd	a7,24(sp)
    2fb6:	86a6                	mv	a3,s1
    2fb8:	85ca                	mv	a1,s2
    2fba:	0d05                	addi	s10,s10,1
    2fbc:	9402                	jalr	s0
    2fbe:	81ab450b          	th.lrbu	a0,s6,s10,0
    2fc2:	68e2                	ld	a7,24(sp)
    2fc4:	8c6a                	mv	s8,s10
    2fc6:	e119                	bnez	a0,2fcc <_vsnprintf+0x6bc>
    2fc8:	22e0106f          	j	41f6 <_vsnprintf+0x18e6>
    2fcc:	8d46                	mv	s10,a7
    2fce:	6882                	ld	a7,0(sp)
    2fd0:	0d888463          	beq	a7,s8,3098 <_vsnprintf+0x788>
    2fd4:	86a6                	mv	a3,s1
    2fd6:	8662                	mv	a2,s8
    2fd8:	85ca                	mv	a1,s2
    2fda:	001c0c93          	addi	s9,s8,1
    2fde:	9402                	jalr	s0
    2fe0:	819b450b          	th.lrbu	a0,s6,s9,0
    2fe4:	e119                	bnez	a0,2fea <_vsnprintf+0x6da>
    2fe6:	20c0106f          	j	41f2 <_vsnprintf+0x18e2>
    2fea:	8666                	mv	a2,s9
    2fec:	86a6                	mv	a3,s1
    2fee:	85ca                	mv	a1,s2
    2ff0:	002c0c93          	addi	s9,s8,2
    2ff4:	9402                	jalr	s0
    2ff6:	819b450b          	th.lrbu	a0,s6,s9,0
    2ffa:	e119                	bnez	a0,3000 <_vsnprintf+0x6f0>
    2ffc:	1f60106f          	j	41f2 <_vsnprintf+0x18e2>
    3000:	86a6                	mv	a3,s1
    3002:	002c0613          	addi	a2,s8,2
    3006:	85ca                	mv	a1,s2
    3008:	003c0c93          	addi	s9,s8,3
    300c:	9402                	jalr	s0
    300e:	819b450b          	th.lrbu	a0,s6,s9,0
    3012:	e119                	bnez	a0,3018 <_vsnprintf+0x708>
    3014:	1de0106f          	j	41f2 <_vsnprintf+0x18e2>
    3018:	86a6                	mv	a3,s1
    301a:	003c0613          	addi	a2,s8,3
    301e:	85ca                	mv	a1,s2
    3020:	004c0c93          	addi	s9,s8,4
    3024:	9402                	jalr	s0
    3026:	819b450b          	th.lrbu	a0,s6,s9,0
    302a:	e119                	bnez	a0,3030 <_vsnprintf+0x720>
    302c:	1c60106f          	j	41f2 <_vsnprintf+0x18e2>
    3030:	86a6                	mv	a3,s1
    3032:	004c0613          	addi	a2,s8,4
    3036:	85ca                	mv	a1,s2
    3038:	005c0c93          	addi	s9,s8,5
    303c:	9402                	jalr	s0
    303e:	819b450b          	th.lrbu	a0,s6,s9,0
    3042:	e119                	bnez	a0,3048 <_vsnprintf+0x738>
    3044:	1ae0106f          	j	41f2 <_vsnprintf+0x18e2>
    3048:	86a6                	mv	a3,s1
    304a:	005c0613          	addi	a2,s8,5
    304e:	85ca                	mv	a1,s2
    3050:	006c0c93          	addi	s9,s8,6
    3054:	9402                	jalr	s0
    3056:	819b450b          	th.lrbu	a0,s6,s9,0
    305a:	e119                	bnez	a0,3060 <_vsnprintf+0x750>
    305c:	1960106f          	j	41f2 <_vsnprintf+0x18e2>
    3060:	86a6                	mv	a3,s1
    3062:	006c0613          	addi	a2,s8,6
    3066:	85ca                	mv	a1,s2
    3068:	007c0c93          	addi	s9,s8,7
    306c:	9402                	jalr	s0
    306e:	819b450b          	th.lrbu	a0,s6,s9,0
    3072:	e119                	bnez	a0,3078 <_vsnprintf+0x768>
    3074:	17e0106f          	j	41f2 <_vsnprintf+0x18e2>
    3078:	86a6                	mv	a3,s1
    307a:	007c0613          	addi	a2,s8,7
    307e:	85ca                	mv	a1,s2
    3080:	008c0c93          	addi	s9,s8,8
    3084:	9402                	jalr	s0
    3086:	819b450b          	th.lrbu	a0,s6,s9,0
    308a:	e119                	bnez	a0,3090 <_vsnprintf+0x780>
    308c:	1660106f          	j	41f2 <_vsnprintf+0x18e2>
    3090:	6882                	ld	a7,0(sp)
    3092:	8c66                	mv	s8,s9
    3094:	f58890e3          	bne	a7,s8,2fd4 <_vsnprintf+0x6c4>
    3098:	88ea                	mv	a7,s10
    309a:	000a9463          	bnez	s5,30a2 <_vsnprintf+0x792>
    309e:	14a0106f          	j	41e8 <_vsnprintf+0x18d8>
    30a2:	6b02                	ld	s6,0(sp)
    30a4:	011be463          	bltu	s7,a7,30ac <_vsnprintf+0x79c>
    30a8:	1400106f          	j	41e8 <_vsnprintf+0x18d8>
    30ac:	6a82                	ld	s5,0(sp)
    30ae:	fff8851b          	addiw	a0,a7,-1
    30b2:	417505bb          	subw	a1,a0,s7
    30b6:	7c05b78b          	th.extu	a5,a1,31,0
    30ba:	001a8b93          	addi	s7,s5,1
    30be:	01778c33          	add	s8,a5,s7
    30c2:	416c0633          	sub	a2,s8,s6
    30c6:	e062                	sd	s8,0(sp)
    30c8:	00767813          	andi	a6,a2,7
    30cc:	08080a63          	beqz	a6,3160 <_vsnprintf+0x850>
    30d0:	4705                	li	a4,1
    30d2:	06e80b63          	beq	a6,a4,3148 <_vsnprintf+0x838>
    30d6:	4f89                	li	t6,2
    30d8:	07f80163          	beq	a6,t6,313a <_vsnprintf+0x82a>
    30dc:	4e0d                	li	t3,3
    30de:	05c80763          	beq	a6,t3,312c <_vsnprintf+0x81c>
    30e2:	4e91                	li	t4,4
    30e4:	03d80d63          	beq	a6,t4,311e <_vsnprintf+0x80e>
    30e8:	4295                	li	t0,5
    30ea:	02580363          	beq	a6,t0,3110 <_vsnprintf+0x800>
    30ee:	4699                	li	a3,6
    30f0:	00d80963          	beq	a6,a3,3102 <_vsnprintf+0x7f2>
    30f4:	865a                	mv	a2,s6
    30f6:	86a6                	mv	a3,s1
    30f8:	85ca                	mv	a1,s2
    30fa:	02000513          	li	a0,32
    30fe:	0b05                	addi	s6,s6,1
    3100:	9402                	jalr	s0
    3102:	865a                	mv	a2,s6
    3104:	86a6                	mv	a3,s1
    3106:	85ca                	mv	a1,s2
    3108:	02000513          	li	a0,32
    310c:	0b05                	addi	s6,s6,1
    310e:	9402                	jalr	s0
    3110:	865a                	mv	a2,s6
    3112:	86a6                	mv	a3,s1
    3114:	85ca                	mv	a1,s2
    3116:	02000513          	li	a0,32
    311a:	0b05                	addi	s6,s6,1
    311c:	9402                	jalr	s0
    311e:	865a                	mv	a2,s6
    3120:	86a6                	mv	a3,s1
    3122:	85ca                	mv	a1,s2
    3124:	02000513          	li	a0,32
    3128:	0b05                	addi	s6,s6,1
    312a:	9402                	jalr	s0
    312c:	865a                	mv	a2,s6
    312e:	86a6                	mv	a3,s1
    3130:	85ca                	mv	a1,s2
    3132:	02000513          	li	a0,32
    3136:	0b05                	addi	s6,s6,1
    3138:	9402                	jalr	s0
    313a:	865a                	mv	a2,s6
    313c:	86a6                	mv	a3,s1
    313e:	85ca                	mv	a1,s2
    3140:	02000513          	li	a0,32
    3144:	0b05                	addi	s6,s6,1
    3146:	9402                	jalr	s0
    3148:	865a                	mv	a2,s6
    314a:	86a6                	mv	a3,s1
    314c:	85ca                	mv	a1,s2
    314e:	02000513          	li	a0,32
    3152:	9402                	jalr	s0
    3154:	6302                	ld	t1,0(sp)
    3156:	0b05                	addi	s6,s6,1
    3158:	006b1463          	bne	s6,t1,3160 <_vsnprintf+0x850>
    315c:	08c0106f          	j	41e8 <_vsnprintf+0x18d8>
    3160:	865a                	mv	a2,s6
    3162:	86a6                	mv	a3,s1
    3164:	85ca                	mv	a1,s2
    3166:	02000513          	li	a0,32
    316a:	9402                	jalr	s0
    316c:	001b0d13          	addi	s10,s6,1
    3170:	866a                	mv	a2,s10
    3172:	86a6                	mv	a3,s1
    3174:	85ca                	mv	a1,s2
    3176:	02000513          	li	a0,32
    317a:	9402                	jalr	s0
    317c:	002b0c93          	addi	s9,s6,2
    3180:	8666                	mv	a2,s9
    3182:	86a6                	mv	a3,s1
    3184:	85ca                	mv	a1,s2
    3186:	02000513          	li	a0,32
    318a:	9402                	jalr	s0
    318c:	003b0a93          	addi	s5,s6,3
    3190:	86a6                	mv	a3,s1
    3192:	8656                	mv	a2,s5
    3194:	85ca                	mv	a1,s2
    3196:	02000513          	li	a0,32
    319a:	9402                	jalr	s0
    319c:	004b0b93          	addi	s7,s6,4
    31a0:	86a6                	mv	a3,s1
    31a2:	865e                	mv	a2,s7
    31a4:	85ca                	mv	a1,s2
    31a6:	02000513          	li	a0,32
    31aa:	9402                	jalr	s0
    31ac:	005b0c13          	addi	s8,s6,5
    31b0:	86a6                	mv	a3,s1
    31b2:	8662                	mv	a2,s8
    31b4:	85ca                	mv	a1,s2
    31b6:	02000513          	li	a0,32
    31ba:	9402                	jalr	s0
    31bc:	006b0d13          	addi	s10,s6,6
    31c0:	86a6                	mv	a3,s1
    31c2:	866a                	mv	a2,s10
    31c4:	85ca                	mv	a1,s2
    31c6:	02000513          	li	a0,32
    31ca:	9402                	jalr	s0
    31cc:	007b0c93          	addi	s9,s6,7
    31d0:	86a6                	mv	a3,s1
    31d2:	8666                	mv	a2,s9
    31d4:	85ca                	mv	a1,s2
    31d6:	02000513          	li	a0,32
    31da:	9402                	jalr	s0
    31dc:	6302                	ld	t1,0(sp)
    31de:	0b21                	addi	s6,s6,8
    31e0:	f86b10e3          	bne	s6,t1,3160 <_vsnprintf+0x850>
    31e4:	0040106f          	j	41e8 <_vsnprintf+0x18d8>
    31e8:	6ea2                	ld	t4,8(sp)
    31ea:	002b6e13          	ori	t3,s6,2
    31ee:	000e0b1b          	sext.w	s6,t3
    31f2:	001e8f13          	addi	t5,t4,1
    31f6:	001ec503          	lbu	a0,1(t4)
    31fa:	411008bb          	negw	a7,a7
    31fe:	e47a                	sd	t5,8(sp)
    3200:	fbeff06f          	j	29be <_vsnprintf+0xae>
    3204:	6e22                	ld	t3,8(sp)
    3206:	06c00d13          	li	s10,108
    320a:	001e4503          	lbu	a0,1(t3)
    320e:	01a51463          	bne	a0,s10,3216 <_vsnprintf+0x906>
    3212:	25e0106f          	j	4470 <_vsnprintf+0x1b60>
    3216:	100b6b13          	ori	s6,s6,256
    321a:	001e0e93          	addi	t4,t3,1
    321e:	2b01                	sext.w	s6,s6
    3220:	e476                	sd	t4,8(sp)
    3222:	b039                	j	2a30 <_vsnprintf+0x120>
    3224:	67a2                	ld	a5,8(sp)
    3226:	06800593          	li	a1,104
    322a:	0017c503          	lbu	a0,1(a5)
    322e:	00b51463          	bne	a0,a1,3236 <_vsnprintf+0x926>
    3232:	2280106f          	j	445a <_vsnprintf+0x1b4a>
    3236:	080b6f13          	ori	t5,s6,128
    323a:	00178613          	addi	a2,a5,1
    323e:	000f0b1b          	sext.w	s6,t5
    3242:	e432                	sd	a2,8(sp)
    3244:	fecff06f          	j	2a30 <_vsnprintf+0x120>
    3248:	06700693          	li	a3,103
    324c:	0ed503e3          	beq	a0,a3,3b32 <_vsnprintf+0x1222>
    3250:	04700f13          	li	t5,71
    3254:	01e51463          	bne	a0,t5,325c <_vsnprintf+0x94c>
    3258:	1280106f          	j	4380 <_vsnprintf+0x1a70>
    325c:	04500713          	li	a4,69
    3260:	00e51463          	bne	a0,a4,3268 <_vsnprintf+0x958>
    3264:	12a0106f          	j	438e <_vsnprintf+0x1a7e>
    3268:	000db507          	fld	fa0,0(s11)
    326c:	008d8b93          	addi	s7,s11,8
    3270:	a2a52dd3          	feq.d	s11,fa0,fa0
    3274:	000d9463          	bnez	s11,327c <_vsnprintf+0x96c>
    3278:	0e80106f          	j	4360 <_vsnprintf+0x1a50>
    327c:	6d29                	lui	s10,0xa
    327e:	6f8d3787          	fld	fa5,1784(s10) # a6f8 <pow10.0+0x58>
    3282:	a2a793d3          	flt.d	t2,fa5,fa0
    3286:	00038463          	beqz	t2,328e <_vsnprintf+0x97e>
    328a:	0d60106f          	j	4360 <_vsnprintf+0x1a50>
    328e:	6aa9                	lui	s5,0xa
    3290:	6f0ab007          	fld	ft0,1776(s5) # a6f0 <pow10.0+0x50>
    3294:	a20517d3          	flt.d	a5,fa0,ft0
    3298:	c399                	beqz	a5,329e <_vsnprintf+0x98e>
    329a:	0c60106f          	j	4360 <_vsnprintf+0x1a50>
    329e:	f20000d3          	fmv.d.x	ft1,zero
    32a2:	a2151ed3          	flt.d	t4,fa0,ft1
    32a6:	e20506d3          	fmv.x.d	a3,fa0
    32aa:	000e8663          	beqz	t4,32b6 <_vsnprintf+0x9a6>
    32ae:	22a51153          	fneg.d	ft2,fa0
    32b2:	e20106d3          	fmv.x.d	a3,ft2
    32b6:	400b7f93          	andi	t6,s6,1024
    32ba:	4719                	li	a4,6
    32bc:	6f29                	lui	t5,0xa
    32be:	6529                	lui	a0,0xa
    32c0:	43fc170b          	th.mvnez	a4,s8,t6
    32c4:	fb46bc0b          	th.extu	s8,a3,62,52
    32c8:	710f3687          	fld	fa3,1808(t5) # a710 <pow10.0+0x70>
    32cc:	71853707          	fld	fa4,1816(a0) # a718 <pow10.0+0x78>
    32d0:	c01c059b          	addiw	a1,s8,-1023
    32d4:	d20581d3          	fcvt.d.w	ft3,a1
    32d8:	3ff00293          	li	t0,1023
    32dc:	6629                	lui	a2,0xa
    32de:	72063287          	fld	ft5,1824(a2) # a720 <pow10.0+0x80>
    32e2:	03429313          	slli	t1,t0,0x34
    32e6:	cc06b80b          	th.extu	a6,a3,51,0
    32ea:	72d1f243          	fmadd.d	ft4,ft3,fa3,fa4
    32ee:	00686e33          	or	t3,a6,t1
    32f2:	f20e0353          	fmv.d.x	ft6,t3
    32f6:	6ca9                	lui	s9,0xa
    32f8:	0a5373d3          	fsub.d	ft7,ft6,ft5
    32fc:	728cb587          	fld	fa1,1832(s9) # a728 <pow10.0+0x88>
    3300:	63a9                	lui	t2,0xa
    3302:	6aa9                	lui	s5,0xa
    3304:	22b3f643          	fmadd.d	fa2,ft7,fa1,ft4
    3308:	7303b887          	fld	fa7,1840(t2) # a730 <pow10.0+0x90>
    330c:	738abe07          	fld	ft8,1848(s5) # a738 <pow10.0+0x98>
    3310:	6ea9                	lui	t4,0xa
    3312:	740ebf87          	fld	ft11,1856(t4) # a740 <pow10.0+0xa0>
    3316:	c2061d53          	fcvt.w.d	s10,fa2,rtz
    331a:	6c29                	lui	s8,0xa
    331c:	d20d0853          	fcvt.d.w	fa6,s10
    3320:	748c3007          	fld	ft0,1864(s8) # a748 <pow10.0+0xa8>
    3324:	e3187ec3          	fmadd.d	ft9,fa6,fa7,ft8
    3328:	65a9                	lui	a1,0xa
    332a:	7505b687          	fld	fa3,1872(a1) # a750 <pow10.0+0xb0>
    332e:	6f29                	lui	t5,0xa
    3330:	758f3207          	fld	ft4,1880(t5) # a758 <pow10.0+0xb8>
    3334:	c20e97d3          	fcvt.w.d	a5,ft9,rtz
    3338:	6529                	lui	a0,0xa
    333a:	d2078f53          	fcvt.d.w	ft10,a5
    333e:	76053387          	fld	ft7,1888(a0) # a760 <pow10.0+0xc0>
    3342:	13ff77d3          	fmul.d	fa5,ft10,ft11
    3346:	6829                	lui	a6,0xa
    3348:	62a9                	lui	t0,0xa
    334a:	7702bf07          	fld	ft10,1904(t0) # a770 <pow10.0+0xd0>
    334e:	7a0870c7          	fmsub.d	ft1,fa6,ft0,fa5
    3352:	76883807          	fld	fa6,1896(a6) # a768 <pow10.0+0xc8>
    3356:	3ff7831b          	addiw	t1,a5,1023
    335a:	03431e13          	slli	t3,t1,0x34
    335e:	f20e07d3          	fmv.d.x	fa5,t3
    3362:	1210f153          	fmul.d	ft2,ft1,ft1
    3366:	0a1878d3          	fsub.d	fa7,fa6,ft1
    336a:	0210f1d3          	fadd.d	ft3,ft1,ft1
    336e:	f2068053          	fmv.d.x	ft0,a3
    3372:	1ad17753          	fdiv.d	fa4,ft2,fa3
    3376:	000d0d9b          	sext.w	s11,s10
    337a:	024772d3          	fadd.d	ft5,fa4,ft4
    337e:	1a517353          	fdiv.d	ft6,ft2,ft5
    3382:	027375d3          	fadd.d	fa1,ft6,ft7
    3386:	1ab17653          	fdiv.d	fa2,ft2,fa1
    338a:	03167e53          	fadd.d	ft8,fa2,fa7
    338e:	1bc1fed3          	fdiv.d	ft9,ft3,ft8
    3392:	03eeffd3          	fadd.d	ft11,ft9,ft10
    3396:	12fff0d3          	fmul.d	ft1,ft11,fa5
    339a:	a2101653          	flt.d	a2,ft0,ft1
    339e:	c609                	beqz	a2,33a8 <_vsnprintf+0xa98>
    33a0:	1a40f0d3          	fdiv.d	ft1,ft1,ft4
    33a4:	fffd0d9b          	addiw	s11,s10,-1
    33a8:	0c600d13          	li	s10,198
    33ac:	063d8c9b          	addiw	s9,s11,99
    33b0:	73ad0793          	addi	a5,s10,1850
    33b4:	019d33b3          	sltu	t2,s10,s9
    33b8:	00fb77b3          	and	a5,s6,a5
    33bc:	00438e13          	addi	t3,t2,4
    33c0:	8ada                	mv	s5,s6
    33c2:	e399                	bnez	a5,33c8 <_vsnprintf+0xab8>
    33c4:	0990106f          	j	4c5c <_vsnprintf+0x234c>
    33c8:	6c29                	lui	s8,0xa
    33ca:	778c3107          	fld	ft2,1912(s8) # a778 <pow10.0+0xd8>
    33ce:	f20681d3          	fmv.d.x	ft3,a3
    33d2:	a23105d3          	fle.d	a1,ft2,ft3
    33d6:	e199                	bnez	a1,33dc <_vsnprintf+0xacc>
    33d8:	4a00206f          	j	5878 <_vsnprintf+0x2f68>
    33dc:	6f29                	lui	t5,0xa
    33de:	780f3707          	fld	fa4,1920(t5) # a780 <pow10.0+0xe0>
    33e2:	a2e19553          	flt.d	a0,ft3,fa4
    33e6:	e119                	bnez	a0,33ec <_vsnprintf+0xadc>
    33e8:	4900206f          	j	5878 <_vsnprintf+0x2f68>
    33ec:	41b70e3b          	subw	t3,a4,s11
    33f0:	fffe061b          	addiw	a2,t3,-1
    33f4:	00eda733          	slt	a4,s11,a4
    33f8:	40e0160b          	th.mveqz	a2,zero,a4
    33fc:	400b6c93          	ori	s9,s6,1024
    3400:	8732                	mv	a4,a2
    3402:	8db2                	mv	s11,a2
    3404:	000c8d1b          	sext.w	s10,s9
    3408:	002b7a93          	andi	s5,s6,2
    340c:	00089463          	bnez	a7,3414 <_vsnprintf+0xb04>
    3410:	4d20406f          	j	78e2 <_vsnprintf+0x4fd2>
    3414:	000a9463          	bnez	s5,341c <_vsnprintf+0xb0c>
    3418:	4ca0406f          	j	78e2 <_vsnprintf+0x4fd2>
    341c:	87c6                	mv	a5,a7
    341e:	8b6a                	mv	s6,s10
    3420:	4d81                	li	s11,0
    3422:	4a89                	li	s5,2
    3424:	4e01                	li	t3,0
    3426:	f20003d3          	fmv.d.x	ft7,zero
    342a:	a2751c53          	flt.d	s8,fa0,ft7
    342e:	000c0463          	beqz	s8,3436 <_vsnprintf+0xb26>
    3432:	5e10106f          	j	5212 <_vsnprintf+0x2902>
    3436:	75fd                	lui	a1,0xfffff
    3438:	7ff58f13          	addi	t5,a1,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    343c:	6602                	ld	a2,0(sp)
    343e:	01eb7533          	and	a0,s6,t5
    3442:	0005081b          	sext.w	a6,a0
    3446:	f2068553          	fmv.d.x	fa0,a3
    344a:	85ca                	mv	a1,s2
    344c:	86a6                	mv	a3,s1
    344e:	8522                	mv	a0,s0
    3450:	ec72                	sd	t3,24(sp)
    3452:	f046                	sd	a7,32(sp)
    3454:	a2dfd0ef          	jal	e80 <_ftoa>
    3458:	68e2                	ld	a7,24(sp)
    345a:	862a                	mv	a2,a0
    345c:	00089463          	bnez	a7,3464 <_vsnprintf+0xb54>
    3460:	4ff0106f          	j	515e <_vsnprintf+0x284e>
    3464:	020b7813          	andi	a6,s6,32
    3468:	06500293          	li	t0,101
    346c:	00150c93          	addi	s9,a0,1
    3470:	04500513          	li	a0,69
    3474:	86a6                	mv	a3,s1
    3476:	4102950b          	th.mveqz	a0,t0,a6
    347a:	f432                	sd	a2,40(sp)
    347c:	85ca                	mv	a1,s2
    347e:	9402                	jalr	s0
    3480:	41fdd31b          	sraiw	t1,s11,0x1f
    3484:	006dc633          	xor	a2,s11,t1
    3488:	4066073b          	subw	a4,a2,t1
    348c:	43a9                	li	t2,10
    348e:	02777fb3          	remu	t6,a4,t2
    3492:	03010d13          	addi	s10,sp,48
    3496:	47a5                	li	a5,9
    3498:	6e62                	ld	t3,24(sp)
    349a:	fdd1488b          	th.ldd	a7,t4,(sp),2,4
    349e:	86ea                	mv	a3,s10
    34a0:	030f8b1b          	addiw	s6,t6,48
    34a4:	03610823          	sb	s6,48(sp)
    34a8:	02775533          	divu	a0,a4,t2
    34ac:	10e7fa63          	bgeu	a5,a4,35c0 <_vsnprintf+0xcb0>
    34b0:	03110693          	addi	a3,sp,49
    34b4:	02757c33          	remu	s8,a0,t2
    34b8:	030c059b          	addiw	a1,s8,48
    34bc:	00b68023          	sb	a1,0(a3)
    34c0:	02755f33          	divu	t5,a0,t2
    34c4:	0ea7fe63          	bgeu	a5,a0,35c0 <_vsnprintf+0xcb0>
    34c8:	00168293          	addi	t0,a3,1
    34cc:	0888                	addi	a0,sp,80
    34ce:	0e550963          	beq	a0,t0,35c0 <_vsnprintf+0xcb0>
    34d2:	8696                	mv	a3,t0
    34d4:	027f7833          	remu	a6,t5,t2
    34d8:	0308031b          	addiw	t1,a6,48
    34dc:	00628023          	sb	t1,0(t0)
    34e0:	027f5633          	divu	a2,t5,t2
    34e4:	0de7fe63          	bgeu	a5,t5,35c0 <_vsnprintf+0xcb0>
    34e8:	02767733          	remu	a4,a2,t2
    34ec:	03070f9b          	addiw	t6,a4,48
    34f0:	0816df8b          	th.sbib	t6,(a3),1,0
    34f4:	02765b33          	divu	s6,a2,t2
    34f8:	0cc7f463          	bgeu	a5,a2,35c0 <_vsnprintf+0xcb0>
    34fc:	00228693          	addi	a3,t0,2
    3500:	027b7c33          	remu	s8,s6,t2
    3504:	030c059b          	addiw	a1,s8,48
    3508:	00b28123          	sb	a1,2(t0)
    350c:	027b5f33          	divu	t5,s6,t2
    3510:	0b67f863          	bgeu	a5,s6,35c0 <_vsnprintf+0xcb0>
    3514:	00328693          	addi	a3,t0,3
    3518:	027f7533          	remu	a0,t5,t2
    351c:	0305081b          	addiw	a6,a0,48
    3520:	010281a3          	sb	a6,3(t0)
    3524:	027f5333          	divu	t1,t5,t2
    3528:	09e7fc63          	bgeu	a5,t5,35c0 <_vsnprintf+0xcb0>
    352c:	00428693          	addi	a3,t0,4
    3530:	02737633          	remu	a2,t1,t2
    3534:	0306071b          	addiw	a4,a2,48
    3538:	00e28223          	sb	a4,4(t0)
    353c:	02735fb3          	divu	t6,t1,t2
    3540:	0867f063          	bgeu	a5,t1,35c0 <_vsnprintf+0xcb0>
    3544:	00528693          	addi	a3,t0,5
    3548:	027ffb33          	remu	s6,t6,t2
    354c:	030b0c1b          	addiw	s8,s6,48
    3550:	018282a3          	sb	s8,5(t0)
    3554:	027fd5b3          	divu	a1,t6,t2
    3558:	07f7f463          	bgeu	a5,t6,35c0 <_vsnprintf+0xcb0>
    355c:	00628693          	addi	a3,t0,6
    3560:	0275ff33          	remu	t5,a1,t2
    3564:	030f051b          	addiw	a0,t5,48
    3568:	00a28323          	sb	a0,6(t0)
    356c:	0275d333          	divu	t1,a1,t2
    3570:	04b7f863          	bgeu	a5,a1,35c0 <_vsnprintf+0xcb0>
    3574:	00728693          	addi	a3,t0,7
    3578:	02737833          	remu	a6,t1,t2
    357c:	0308061b          	addiw	a2,a6,48
    3580:	00c283a3          	sb	a2,7(t0)
    3584:	02735733          	divu	a4,t1,t2
    3588:	0267fc63          	bgeu	a5,t1,35c0 <_vsnprintf+0xcb0>
    358c:	00828693          	addi	a3,t0,8
    3590:	02777fb3          	remu	t6,a4,t2
    3594:	030f8b1b          	addiw	s6,t6,48
    3598:	01628423          	sb	s6,8(t0)
    359c:	02775533          	divu	a0,a4,t2
    35a0:	02e7f063          	bgeu	a5,a4,35c0 <_vsnprintf+0xcb0>
    35a4:	00928693          	addi	a3,t0,9
    35a8:	02757c33          	remu	s8,a0,t2
    35ac:	030c059b          	addiw	a1,s8,48
    35b0:	00b68023          	sb	a1,0(a3)
    35b4:	02755f33          	divu	t5,a0,t2
    35b8:	f0a7e8e3          	bltu	a5,a0,34c8 <_vsnprintf+0xbb8>
    35bc:	00000013          	nop
    35c0:	4385                	li	t2,1
    35c2:	41a387b3          	sub	a5,t2,s10
    35c6:	00d78c33          	add	s8,a5,a3
    35ca:	ffee069b          	addiw	a3,t3,-2
    35ce:	7c06b28b          	th.extu	t0,a3,31,0
    35d2:	005c6463          	bltu	s8,t0,35da <_vsnprintf+0xcca>
    35d6:	0640306f          	j	663a <_vsnprintf+0x3d2a>
    35da:	018d07b3          	add	a5,s10,s8
    35de:	005d0f33          	add	t5,s10,t0
    35e2:	40ff05b3          	sub	a1,t5,a5
    35e6:	0075f613          	andi	a2,a1,7
    35ea:	03000313          	li	t1,48
    35ee:	e219                	bnez	a2,35f4 <_vsnprintf+0xce4>
    35f0:	3330106f          	j	5122 <_vsnprintf+0x2812>
    35f4:	02760e63          	beq	a2,t2,3630 <_vsnprintf+0xd20>
    35f8:	4809                	li	a6,2
    35fa:	03060963          	beq	a2,a6,362c <_vsnprintf+0xd1c>
    35fe:	470d                	li	a4,3
    3600:	02e60463          	beq	a2,a4,3628 <_vsnprintf+0xd18>
    3604:	4f91                	li	t6,4
    3606:	01f60f63          	beq	a2,t6,3624 <_vsnprintf+0xd14>
    360a:	4b15                	li	s6,5
    360c:	01660a63          	beq	a2,s6,3620 <_vsnprintf+0xd10>
    3610:	4519                	li	a0,6
    3612:	00a60563          	beq	a2,a0,361c <_vsnprintf+0xd0c>
    3616:	018d530b          	th.srb	t1,s10,s8,0
    361a:	0785                	addi	a5,a5,1
    361c:	1817d30b          	th.sbia	t1,(a5),1,0
    3620:	1817d30b          	th.sbia	t1,(a5),1,0
    3624:	1817d30b          	th.sbia	t1,(a5),1,0
    3628:	1817d30b          	th.sbia	t1,(a5),1,0
    362c:	1817d30b          	th.sbia	t1,(a5),1,0
    3630:	1817d30b          	th.sbia	t1,(a5),1,0
    3634:	01e78463          	beq	a5,t5,363c <_vsnprintf+0xd2c>
    3638:	2eb0106f          	j	5122 <_vsnprintf+0x2812>
    363c:	02028393          	addi	t2,t0,32
    3640:	1814                	addi	a3,sp,48
    3642:	00128c13          	addi	s8,t0,1
    3646:	00d38e33          	add	t3,t2,a3
    364a:	000dc463          	bltz	s11,3652 <_vsnprintf+0xd42>
    364e:	5a70306f          	j	73f4 <_vsnprintf+0x4ae4>
    3652:	02d00513          	li	a0,45
    3656:	feae0023          	sb	a0,-32(t3)
    365a:	018d0db3          	add	s11,s10,s8
    365e:	fffd4f13          	not	t5,s10
    3662:	001d0293          	addi	t0,s10,1
    3666:	01bf0333          	add	t1,t5,s11
    366a:	9e96                	add	t4,t4,t0
    366c:	00737813          	andi	a6,t1,7
    3670:	018e8b33          	add	s6,t4,s8
    3674:	00081463          	bnez	a6,367c <_vsnprintf+0xd6c>
    3678:	5e10306f          	j	7458 <_vsnprintf+0x4b48>
    367c:	41bb0633          	sub	a2,s6,s11
    3680:	ec46                	sd	a7,24(sp)
    3682:	f042                	sd	a6,32(sp)
    3684:	85ca                	mv	a1,s2
    3686:	86a6                	mv	a3,s1
    3688:	9402                	jalr	s0
    368a:	68e2                	ld	a7,24(sp)
    368c:	7602                	ld	a2,32(sp)
    368e:	4585                	li	a1,1
    3690:	1dfd                	addi	s11,s11,-1
    3692:	fffdc503          	lbu	a0,-1(s11)
    3696:	00b61463          	bne	a2,a1,369e <_vsnprintf+0xd8e>
    369a:	5bf0306f          	j	7458 <_vsnprintf+0x4b48>
    369e:	4709                	li	a4,2
    36a0:	06e60f63          	beq	a2,a4,371e <_vsnprintf+0xe0e>
    36a4:	4f8d                	li	t6,3
    36a6:	07f60263          	beq	a2,t6,370a <_vsnprintf+0xdfa>
    36aa:	4791                	li	a5,4
    36ac:	04f60563          	beq	a2,a5,36f6 <_vsnprintf+0xde6>
    36b0:	4395                	li	t2,5
    36b2:	02760863          	beq	a2,t2,36e2 <_vsnprintf+0xdd2>
    36b6:	4699                	li	a3,6
    36b8:	00d60b63          	beq	a2,a3,36ce <_vsnprintf+0xdbe>
    36bc:	41bb0633          	sub	a2,s6,s11
    36c0:	86a6                	mv	a3,s1
    36c2:	85ca                	mv	a1,s2
    36c4:	9402                	jalr	s0
    36c6:	68e2                	ld	a7,24(sp)
    36c8:	ffedc503          	lbu	a0,-2(s11)
    36cc:	1dfd                	addi	s11,s11,-1
    36ce:	41bb0633          	sub	a2,s6,s11
    36d2:	ec46                	sd	a7,24(sp)
    36d4:	86a6                	mv	a3,s1
    36d6:	85ca                	mv	a1,s2
    36d8:	9402                	jalr	s0
    36da:	68e2                	ld	a7,24(sp)
    36dc:	ffedc503          	lbu	a0,-2(s11)
    36e0:	1dfd                	addi	s11,s11,-1
    36e2:	41bb0633          	sub	a2,s6,s11
    36e6:	ec46                	sd	a7,24(sp)
    36e8:	86a6                	mv	a3,s1
    36ea:	85ca                	mv	a1,s2
    36ec:	9402                	jalr	s0
    36ee:	68e2                	ld	a7,24(sp)
    36f0:	ffedc503          	lbu	a0,-2(s11)
    36f4:	1dfd                	addi	s11,s11,-1
    36f6:	41bb0633          	sub	a2,s6,s11
    36fa:	ec46                	sd	a7,24(sp)
    36fc:	86a6                	mv	a3,s1
    36fe:	85ca                	mv	a1,s2
    3700:	9402                	jalr	s0
    3702:	68e2                	ld	a7,24(sp)
    3704:	ffedc503          	lbu	a0,-2(s11)
    3708:	1dfd                	addi	s11,s11,-1
    370a:	41bb0633          	sub	a2,s6,s11
    370e:	ec46                	sd	a7,24(sp)
    3710:	86a6                	mv	a3,s1
    3712:	85ca                	mv	a1,s2
    3714:	9402                	jalr	s0
    3716:	68e2                	ld	a7,24(sp)
    3718:	ffedc503          	lbu	a0,-2(s11)
    371c:	1dfd                	addi	s11,s11,-1
    371e:	41bb0633          	sub	a2,s6,s11
    3722:	86a6                	mv	a3,s1
    3724:	85ca                	mv	a1,s2
    3726:	ec46                	sd	a7,24(sp)
    3728:	9402                	jalr	s0
    372a:	1dfd                	addi	s11,s11,-1
    372c:	fd515b8b          	th.sdd	s7,s5,(sp),2,4
    3730:	fffdc503          	lbu	a0,-1(s11)
    3734:	a895                	j	37a8 <_vsnprintf+0xe98>
    3736:	8bee                	mv	s7,s11
    3738:	89ebc50b          	th.lbuib	a0,(s7),-2,0
    373c:	415b0633          	sub	a2,s6,s5
    3740:	86a6                	mv	a3,s1
    3742:	85ca                	mv	a1,s2
    3744:	9402                	jalr	s0
    3746:	8aee                	mv	s5,s11
    3748:	89dac50b          	th.lbuib	a0,(s5),-3,0
    374c:	417b0633          	sub	a2,s6,s7
    3750:	86a6                	mv	a3,s1
    3752:	85ca                	mv	a1,s2
    3754:	9402                	jalr	s0
    3756:	8bee                	mv	s7,s11
    3758:	89cbc50b          	th.lbuib	a0,(s7),-4,0
    375c:	415b0633          	sub	a2,s6,s5
    3760:	86a6                	mv	a3,s1
    3762:	85ca                	mv	a1,s2
    3764:	9402                	jalr	s0
    3766:	8aee                	mv	s5,s11
    3768:	89bac50b          	th.lbuib	a0,(s5),-5,0
    376c:	417b0633          	sub	a2,s6,s7
    3770:	86a6                	mv	a3,s1
    3772:	85ca                	mv	a1,s2
    3774:	9402                	jalr	s0
    3776:	8bee                	mv	s7,s11
    3778:	89abc50b          	th.lbuib	a0,(s7),-6,0
    377c:	415b0633          	sub	a2,s6,s5
    3780:	86a6                	mv	a3,s1
    3782:	85ca                	mv	a1,s2
    3784:	9402                	jalr	s0
    3786:	8aee                	mv	s5,s11
    3788:	899ac50b          	th.lbuib	a0,(s5),-7,0
    378c:	86a6                	mv	a3,s1
    378e:	417b0633          	sub	a2,s6,s7
    3792:	85ca                	mv	a1,s2
    3794:	9402                	jalr	s0
    3796:	898dc50b          	th.lbuib	a0,(s11),-8,0
    379a:	86a6                	mv	a3,s1
    379c:	415b0633          	sub	a2,s6,s5
    37a0:	85ca                	mv	a1,s2
    37a2:	9402                	jalr	s0
    37a4:	fffdc503          	lbu	a0,-1(s11)
    37a8:	86a6                	mv	a3,s1
    37aa:	41bb0633          	sub	a2,s6,s11
    37ae:	85ca                	mv	a1,s2
    37b0:	fffd8a93          	addi	s5,s11,-1
    37b4:	9402                	jalr	s0
    37b6:	f95d10e3          	bne	s10,s5,3736 <_vsnprintf+0xe26>
    37ba:	fda14b8b          	th.ldd	s7,s10,(sp),2,4
    37be:	018c8633          	add	a2,s9,s8
    37c2:	6ce2                	ld	s9,24(sp)
    37c4:	000d1463          	bnez	s10,37cc <_vsnprintf+0xebc>
    37c8:	1970106f          	j	515e <_vsnprintf+0x284e>
    37cc:	6502                	ld	a0,0(sp)
    37ce:	7c0cbd8b          	th.extu	s11,s9,31,0
    37d2:	40a60ab3          	sub	s5,a2,a0
    37d6:	01bae463          	bltu	s5,s11,37de <_vsnprintf+0xece>
    37da:	1850106f          	j	515e <_vsnprintf+0x284e>
    37de:	fffacc13          	not	s8,s5
    37e2:	01bc0e33          	add	t3,s8,s11
    37e6:	86a6                	mv	a3,s1
    37e8:	85ca                	mv	a1,s2
    37ea:	02000513          	li	a0,32
    37ee:	001a8d13          	addi	s10,s5,1
    37f2:	007e7c93          	andi	s9,t3,7
    37f6:	00160b13          	addi	s6,a2,1
    37fa:	9402                	jalr	s0
    37fc:	13bd7263          	bgeu	s10,s11,3920 <_vsnprintf+0x1010>
    3800:	080c8e63          	beqz	s9,389c <_vsnprintf+0xf8c>
    3804:	4285                	li	t0,1
    3806:	085c8163          	beq	s9,t0,3888 <_vsnprintf+0xf78>
    380a:	4e89                	li	t4,2
    380c:	07dc8663          	beq	s9,t4,3878 <_vsnprintf+0xf68>
    3810:	4f0d                	li	t5,3
    3812:	05ec8b63          	beq	s9,t5,3868 <_vsnprintf+0xf58>
    3816:	4311                	li	t1,4
    3818:	046c8063          	beq	s9,t1,3858 <_vsnprintf+0xf48>
    381c:	4815                	li	a6,5
    381e:	030c8563          	beq	s9,a6,3848 <_vsnprintf+0xf38>
    3822:	4599                	li	a1,6
    3824:	00bc8a63          	beq	s9,a1,3838 <_vsnprintf+0xf28>
    3828:	865a                	mv	a2,s6
    382a:	86a6                	mv	a3,s1
    382c:	85ca                	mv	a1,s2
    382e:	02000513          	li	a0,32
    3832:	0b05                	addi	s6,s6,1
    3834:	9402                	jalr	s0
    3836:	0d05                	addi	s10,s10,1
    3838:	865a                	mv	a2,s6
    383a:	86a6                	mv	a3,s1
    383c:	85ca                	mv	a1,s2
    383e:	02000513          	li	a0,32
    3842:	0b05                	addi	s6,s6,1
    3844:	9402                	jalr	s0
    3846:	0d05                	addi	s10,s10,1
    3848:	865a                	mv	a2,s6
    384a:	86a6                	mv	a3,s1
    384c:	85ca                	mv	a1,s2
    384e:	02000513          	li	a0,32
    3852:	0b05                	addi	s6,s6,1
    3854:	9402                	jalr	s0
    3856:	0d05                	addi	s10,s10,1
    3858:	865a                	mv	a2,s6
    385a:	86a6                	mv	a3,s1
    385c:	85ca                	mv	a1,s2
    385e:	02000513          	li	a0,32
    3862:	0b05                	addi	s6,s6,1
    3864:	9402                	jalr	s0
    3866:	0d05                	addi	s10,s10,1
    3868:	865a                	mv	a2,s6
    386a:	86a6                	mv	a3,s1
    386c:	85ca                	mv	a1,s2
    386e:	02000513          	li	a0,32
    3872:	0b05                	addi	s6,s6,1
    3874:	9402                	jalr	s0
    3876:	0d05                	addi	s10,s10,1
    3878:	865a                	mv	a2,s6
    387a:	86a6                	mv	a3,s1
    387c:	85ca                	mv	a1,s2
    387e:	02000513          	li	a0,32
    3882:	0b05                	addi	s6,s6,1
    3884:	9402                	jalr	s0
    3886:	0d05                	addi	s10,s10,1
    3888:	865a                	mv	a2,s6
    388a:	86a6                	mv	a3,s1
    388c:	85ca                	mv	a1,s2
    388e:	02000513          	li	a0,32
    3892:	0d05                	addi	s10,s10,1
    3894:	0b05                	addi	s6,s6,1
    3896:	9402                	jalr	s0
    3898:	09bd7463          	bgeu	s10,s11,3920 <_vsnprintf+0x1010>
    389c:	865a                	mv	a2,s6
    389e:	86a6                	mv	a3,s1
    38a0:	85ca                	mv	a1,s2
    38a2:	02000513          	li	a0,32
    38a6:	9402                	jalr	s0
    38a8:	001b0a93          	addi	s5,s6,1
    38ac:	8656                	mv	a2,s5
    38ae:	86a6                	mv	a3,s1
    38b0:	85ca                	mv	a1,s2
    38b2:	02000513          	li	a0,32
    38b6:	9402                	jalr	s0
    38b8:	002b0c13          	addi	s8,s6,2
    38bc:	8662                	mv	a2,s8
    38be:	86a6                	mv	a3,s1
    38c0:	85ca                	mv	a1,s2
    38c2:	02000513          	li	a0,32
    38c6:	9402                	jalr	s0
    38c8:	003b0c93          	addi	s9,s6,3
    38cc:	8666                	mv	a2,s9
    38ce:	86a6                	mv	a3,s1
    38d0:	85ca                	mv	a1,s2
    38d2:	02000513          	li	a0,32
    38d6:	9402                	jalr	s0
    38d8:	004b0c13          	addi	s8,s6,4
    38dc:	8662                	mv	a2,s8
    38de:	86a6                	mv	a3,s1
    38e0:	85ca                	mv	a1,s2
    38e2:	02000513          	li	a0,32
    38e6:	9402                	jalr	s0
    38e8:	005b0a93          	addi	s5,s6,5
    38ec:	86a6                	mv	a3,s1
    38ee:	8656                	mv	a2,s5
    38f0:	85ca                	mv	a1,s2
    38f2:	02000513          	li	a0,32
    38f6:	9402                	jalr	s0
    38f8:	006b0c93          	addi	s9,s6,6
    38fc:	86a6                	mv	a3,s1
    38fe:	8666                	mv	a2,s9
    3900:	85ca                	mv	a1,s2
    3902:	02000513          	li	a0,32
    3906:	9402                	jalr	s0
    3908:	007b0c13          	addi	s8,s6,7
    390c:	86a6                	mv	a3,s1
    390e:	8662                	mv	a2,s8
    3910:	85ca                	mv	a1,s2
    3912:	02000513          	li	a0,32
    3916:	0d21                	addi	s10,s10,8
    3918:	0b21                	addi	s6,s6,8
    391a:	9402                	jalr	s0
    391c:	f9bd60e3          	bltu	s10,s11,389c <_vsnprintf+0xf8c>
    3920:	e05a                	sd	s6,0(sp)
    3922:	2530006f          	j	4374 <_vsnprintf+0x1a64>
    3926:	0001                	nop
    3928:	000db507          	fld	fa0,0(s11)
    392c:	020b6793          	ori	a5,s6,32
    3930:	6602                	ld	a2,0(sp)
    3932:	fba50e93          	addi	t4,a0,-70
    3936:	0007881b          	sext.w	a6,a5
    393a:	008d8f93          	addi	t6,s11,8
    393e:	85ca                	mv	a1,s2
    3940:	43db180b          	th.mvnez	a6,s6,t4
    3944:	87c6                	mv	a5,a7
    3946:	8762                	mv	a4,s8
    3948:	86a6                	mv	a3,s1
    394a:	8522                	mv	a0,s0
    394c:	8dfe                	mv	s11,t6
    394e:	d32fd0ef          	jal	e80 <_ftoa>
    3952:	65a2                	ld	a1,8(sp)
    3954:	e02a                	sd	a0,0(sp)
    3956:	00158c93          	addi	s9,a1,1
    395a:	816ff06f          	j	2970 <_vsnprintf+0x60>
    395e:	002b7b13          	andi	s6,s6,2
    3962:	320b0de3          	beqz	s6,449c <_vsnprintf+0x1b8c>
    3966:	6602                	ld	a2,0(sp)
    3968:	988dc50b          	th.lbuia	a0,(s11),8,0
    396c:	86a6                	mv	a3,s1
    396e:	85ca                	mv	a1,s2
    3970:	ec46                	sd	a7,24(sp)
    3972:	00160b13          	addi	s6,a2,1
    3976:	9402                	jalr	s0
    3978:	6c62                	ld	s8,24(sp)
    397a:	4285                	li	t0,1
    397c:	0782f2e3          	bgeu	t0,s8,41e0 <_vsnprintf+0x18d0>
    3980:	6b82                	ld	s7,0(sp)
    3982:	ffec051b          	addiw	a0,s8,-2
    3986:	7c053e8b          	th.extu	t4,a0,31,0
    398a:	002b8a93          	addi	s5,s7,2
    398e:	015e8e33          	add	t3,t4,s5
    3992:	416e0f33          	sub	t5,t3,s6
    3996:	e072                	sd	t3,0(sp)
    3998:	007f7593          	andi	a1,t5,7
    399c:	c5d1                	beqz	a1,3a28 <_vsnprintf+0x1118>
    399e:	06558b63          	beq	a1,t0,3a14 <_vsnprintf+0x1104>
    39a2:	4889                	li	a7,2
    39a4:	07158163          	beq	a1,a7,3a06 <_vsnprintf+0x10f6>
    39a8:	470d                	li	a4,3
    39aa:	04e58763          	beq	a1,a4,39f8 <_vsnprintf+0x10e8>
    39ae:	4611                	li	a2,4
    39b0:	02c58d63          	beq	a1,a2,39ea <_vsnprintf+0x10da>
    39b4:	4795                	li	a5,5
    39b6:	02f58363          	beq	a1,a5,39dc <_vsnprintf+0x10cc>
    39ba:	4d19                	li	s10,6
    39bc:	01a58963          	beq	a1,s10,39ce <_vsnprintf+0x10be>
    39c0:	865a                	mv	a2,s6
    39c2:	86a6                	mv	a3,s1
    39c4:	85ca                	mv	a1,s2
    39c6:	02000513          	li	a0,32
    39ca:	0b05                	addi	s6,s6,1
    39cc:	9402                	jalr	s0
    39ce:	865a                	mv	a2,s6
    39d0:	86a6                	mv	a3,s1
    39d2:	85ca                	mv	a1,s2
    39d4:	02000513          	li	a0,32
    39d8:	0b05                	addi	s6,s6,1
    39da:	9402                	jalr	s0
    39dc:	865a                	mv	a2,s6
    39de:	86a6                	mv	a3,s1
    39e0:	85ca                	mv	a1,s2
    39e2:	02000513          	li	a0,32
    39e6:	0b05                	addi	s6,s6,1
    39e8:	9402                	jalr	s0
    39ea:	865a                	mv	a2,s6
    39ec:	86a6                	mv	a3,s1
    39ee:	85ca                	mv	a1,s2
    39f0:	02000513          	li	a0,32
    39f4:	0b05                	addi	s6,s6,1
    39f6:	9402                	jalr	s0
    39f8:	865a                	mv	a2,s6
    39fa:	86a6                	mv	a3,s1
    39fc:	85ca                	mv	a1,s2
    39fe:	02000513          	li	a0,32
    3a02:	0b05                	addi	s6,s6,1
    3a04:	9402                	jalr	s0
    3a06:	865a                	mv	a2,s6
    3a08:	86a6                	mv	a3,s1
    3a0a:	85ca                	mv	a1,s2
    3a0c:	02000513          	li	a0,32
    3a10:	0b05                	addi	s6,s6,1
    3a12:	9402                	jalr	s0
    3a14:	865a                	mv	a2,s6
    3a16:	86a6                	mv	a3,s1
    3a18:	85ca                	mv	a1,s2
    3a1a:	02000513          	li	a0,32
    3a1e:	9402                	jalr	s0
    3a20:	6c82                	ld	s9,0(sp)
    3a22:	0b05                	addi	s6,s6,1
    3a24:	7d9b0263          	beq	s6,s9,41e8 <_vsnprintf+0x18d8>
    3a28:	865a                	mv	a2,s6
    3a2a:	86a6                	mv	a3,s1
    3a2c:	85ca                	mv	a1,s2
    3a2e:	02000513          	li	a0,32
    3a32:	9402                	jalr	s0
    3a34:	001b0c13          	addi	s8,s6,1
    3a38:	8662                	mv	a2,s8
    3a3a:	86a6                	mv	a3,s1
    3a3c:	85ca                	mv	a1,s2
    3a3e:	02000513          	li	a0,32
    3a42:	9402                	jalr	s0
    3a44:	002b0b93          	addi	s7,s6,2
    3a48:	865e                	mv	a2,s7
    3a4a:	86a6                	mv	a3,s1
    3a4c:	85ca                	mv	a1,s2
    3a4e:	02000513          	li	a0,32
    3a52:	9402                	jalr	s0
    3a54:	003b0a93          	addi	s5,s6,3
    3a58:	86a6                	mv	a3,s1
    3a5a:	8656                	mv	a2,s5
    3a5c:	85ca                	mv	a1,s2
    3a5e:	02000513          	li	a0,32
    3a62:	9402                	jalr	s0
    3a64:	004b0d13          	addi	s10,s6,4
    3a68:	86a6                	mv	a3,s1
    3a6a:	866a                	mv	a2,s10
    3a6c:	85ca                	mv	a1,s2
    3a6e:	02000513          	li	a0,32
    3a72:	9402                	jalr	s0
    3a74:	005b0c93          	addi	s9,s6,5
    3a78:	8666                	mv	a2,s9
    3a7a:	86a6                	mv	a3,s1
    3a7c:	85ca                	mv	a1,s2
    3a7e:	02000513          	li	a0,32
    3a82:	9402                	jalr	s0
    3a84:	006b0c13          	addi	s8,s6,6
    3a88:	86a6                	mv	a3,s1
    3a8a:	8662                	mv	a2,s8
    3a8c:	85ca                	mv	a1,s2
    3a8e:	02000513          	li	a0,32
    3a92:	9402                	jalr	s0
    3a94:	007b0b93          	addi	s7,s6,7
    3a98:	86a6                	mv	a3,s1
    3a9a:	865e                	mv	a2,s7
    3a9c:	85ca                	mv	a1,s2
    3a9e:	02000513          	li	a0,32
    3aa2:	9402                	jalr	s0
    3aa4:	6c82                	ld	s9,0(sp)
    3aa6:	0b21                	addi	s6,s6,8
    3aa8:	f99b10e3          	bne	s6,s9,3a28 <_vsnprintf+0x1118>
    3aac:	af35                	j	41e8 <_vsnprintf+0x18d8>
    3aae:	0001                	nop
    3ab0:	6602                	ld	a2,0(sp)
    3ab2:	86a6                	mv	a3,s1
    3ab4:	85ca                	mv	a1,s2
    3ab6:	02500513          	li	a0,37
    3aba:	00160b13          	addi	s6,a2,1
    3abe:	9402                	jalr	s0
    3ac0:	6722                	ld	a4,8(sp)
    3ac2:	e05a                	sd	s6,0(sp)
    3ac4:	00170c93          	addi	s9,a4,1
    3ac8:	ea9fe06f          	j	2970 <_vsnprintf+0x60>
    3acc:	06f00313          	li	t1,111
    3ad0:	06650a63          	beq	a0,t1,3b44 <_vsnprintf+0x1234>
    3ad4:	00a36463          	bltu	t1,a0,3adc <_vsnprintf+0x11cc>
    3ad8:	5c90106f          	j	58a0 <_vsnprintf+0x2f90>
    3adc:	07800393          	li	t2,120
    3ae0:	00751463          	bne	a0,t2,3ae8 <_vsnprintf+0x11d8>
    3ae4:	2a80106f          	j	4d8c <_vsnprintf+0x247c>
    3ae8:	fefb7513          	andi	a0,s6,-17
    3aec:	47a9                	li	a5,10
    3aee:	00050b1b          	sext.w	s6,a0
    3af2:	86be                	mv	a3,a5
    3af4:	a891                	j	3b48 <_vsnprintf+0x1238>
    3af6:	588dc50b          	th.lwia	a0,(s11),8,0
    3afa:	6e22                	ld	t3,8(sp)
    3afc:	00052c13          	slti	s8,a0,0
    3b00:	4380150b          	th.mvnez	a0,zero,s8
    3b04:	002e0e93          	addi	t4,t3,2
    3b08:	00050c1b          	sext.w	s8,a0
    3b0c:	e476                	sd	t4,8(sp)
    3b0e:	002e4503          	lbu	a0,2(t3)
    3b12:	eb7fe06f          	j	29c8 <_vsnprintf+0xb8>
    3b16:	fefb7893          	andi	a7,s6,-17
    3b1a:	0218e593          	ori	a1,a7,33
    3b1e:	400b7c93          	andi	s9,s6,1024
    3b22:	855a                	mv	a0,s6
    3b24:	2581                	sext.w	a1,a1
    3b26:	480c93e3          	bnez	s9,47ac <_vsnprintf+0x1e9c>
    3b2a:	4b81                	li	s7,0
    3b2c:	4281                	li	t0,0
    3b2e:	88cff06f          	j	2bba <_vsnprintf+0x2aa>
    3b32:	6e05                	lui	t3,0x1
    3b34:	800e0613          	addi	a2,t3,-2048 # 800 <Proc_5>
    3b38:	00cb6cb3          	or	s9,s6,a2
    3b3c:	000c8b1b          	sext.w	s6,s9
    3b40:	f28ff06f          	j	3268 <_vsnprintf+0x958>
    3b44:	47a1                	li	a5,8
    3b46:	86be                	mv	a3,a5
    3b48:	ff2b7813          	andi	a6,s6,-14
    3b4c:	400b7b93          	andi	s7,s6,1024
    3b50:	ff3b7b13          	andi	s6,s6,-13
    3b54:	00080c9b          	sext.w	s9,a6
    3b58:	000b061b          	sext.w	a2,s6
    3b5c:	437c960b          	th.mvnez	a2,s9,s7
    3b60:	20067813          	andi	a6,a2,512
    3b64:	8fb2                	mv	t6,a2
    3b66:	00080463          	beqz	a6,3b6e <_vsnprintf+0x125e>
    3b6a:	6b80106f          	j	5222 <_vsnprintf+0x2912>
    3b6e:	10067d13          	andi	s10,a2,256
    3b72:	000d0463          	beqz	s10,3b7a <_vsnprintf+0x126a>
    3b76:	15b0206f          	j	64d0 <_vsnprintf+0x3bc0>
    3b7a:	04067293          	andi	t0,a2,64
    3b7e:	00029463          	bnez	t0,3b86 <_vsnprintf+0x1276>
    3b82:	2560106f          	j	4dd8 <_vsnprintf+0x24c8>
    3b86:	988dce8b          	th.lbuia	t4,(s11),8,0
    3b8a:	7c0eb70b          	th.extu	a4,t4,31,0
    3b8e:	e319                	bnez	a4,3b94 <_vsnprintf+0x1284>
    3b90:	1310206f          	j	64c0 <_vsnprintf+0x3bb0>
    3b94:	01067e93          	andi	t4,a2,16
    3b98:	8e32                	mv	t3,a2
    3b9a:	02f75333          	divu	t1,a4,a5
    3b9e:	853a                	mv	a0,a4
    3ba0:	145e358b          	th.extu	a1,t3,5,5
    3ba4:	fff58a93          	addi	s5,a1,-1
    3ba8:	020af393          	andi	t2,s5,32
    3bac:	03738b1b          	addiw	s6,t2,55
    3bb0:	4ca5                	li	s9,9
    3bb2:	03010813          	addi	a6,sp,48
    3bb6:	8642                	mv	a2,a6
    3bb8:	22f3150b          	th.muls	a0,t1,a5
    3bbc:	0ff57f93          	zext.b	t6,a0
    3bc0:	030f829b          	addiw	t0,t6,48
    3bc4:	01fb05bb          	addw	a1,s6,t6
    3bc8:	0ff2ff13          	zext.b	t5,t0
    3bcc:	0ff5fa93          	zext.b	s5,a1
    3bd0:	00acb3b3          	sltu	t2,s9,a0
    3bd4:	407f1a8b          	th.mveqz	s5,t5,t2
    3bd8:	03510823          	sb	s5,48(sp)
    3bdc:	00f77463          	bgeu	a4,a5,3be4 <_vsnprintf+0x12d4>
    3be0:	7ac0106f          	j	538c <_vsnprintf+0x2a7c>
    3be4:	03110613          	addi	a2,sp,49
    3be8:	829a                	mv	t0,t1
    3bea:	0001                	nop
    3bec:	00000013          	nop
    3bf0:	02f2d333          	divu	t1,t0,a5
    3bf4:	8516                	mv	a0,t0
    3bf6:	22f3150b          	th.muls	a0,t1,a5
    3bfa:	0ff57713          	zext.b	a4,a0
    3bfe:	03070f9b          	addiw	t6,a4,48
    3c02:	00eb0f3b          	addw	t5,s6,a4
    3c06:	0ffff593          	zext.b	a1,t6
    3c0a:	0fff7a93          	zext.b	s5,t5
    3c0e:	00acb3b3          	sltu	t2,s9,a0
    3c12:	40759a8b          	th.mveqz	s5,a1,t2
    3c16:	01560023          	sb	s5,0(a2)
    3c1a:	00f2f463          	bgeu	t0,a5,3c22 <_vsnprintf+0x1312>
    3c1e:	76e0106f          	j	538c <_vsnprintf+0x2a7c>
    3c22:	00160513          	addi	a0,a2,1
    3c26:	05010293          	addi	t0,sp,80
    3c2a:	00a29463          	bne	t0,a0,3c32 <_vsnprintf+0x1322>
    3c2e:	75e0106f          	j	538c <_vsnprintf+0x2a7c>
    3c32:	02f35fb3          	divu	t6,t1,a5
    3c36:	859a                	mv	a1,t1
    3c38:	862a                	mv	a2,a0
    3c3a:	22ff958b          	th.muls	a1,t6,a5
    3c3e:	0ff5f713          	zext.b	a4,a1
    3c42:	03070f1b          	addiw	t5,a4,48
    3c46:	00eb03bb          	addw	t2,s6,a4
    3c4a:	0fff7a93          	zext.b	s5,t5
    3c4e:	0ff3f713          	zext.b	a4,t2
    3c52:	00bcb2b3          	sltu	t0,s9,a1
    3c56:	405a970b          	th.mveqz	a4,s5,t0
    3c5a:	00e50023          	sb	a4,0(a0)
    3c5e:	00f37463          	bgeu	t1,a5,3c66 <_vsnprintf+0x1356>
    3c62:	72a0106f          	j	538c <_vsnprintf+0x2a7c>
    3c66:	02ffd333          	divu	t1,t6,a5
    3c6a:	85fe                	mv	a1,t6
    3c6c:	22f3158b          	th.muls	a1,t1,a5
    3c70:	0ff5ff13          	zext.b	t5,a1
    3c74:	030f0a9b          	addiw	s5,t5,48
    3c78:	01eb073b          	addw	a4,s6,t5
    3c7c:	0ffaf393          	zext.b	t2,s5
    3c80:	0ff77f13          	zext.b	t5,a4
    3c84:	00bcb2b3          	sltu	t0,s9,a1
    3c88:	40539f0b          	th.mveqz	t5,t2,t0
    3c8c:	08165f0b          	th.sbib	t5,(a2),1,0
    3c90:	00fff463          	bgeu	t6,a5,3c98 <_vsnprintf+0x1388>
    3c94:	6f80106f          	j	538c <_vsnprintf+0x2a7c>
    3c98:	02f35fb3          	divu	t6,t1,a5
    3c9c:	859a                	mv	a1,t1
    3c9e:	00250613          	addi	a2,a0,2
    3ca2:	22ff958b          	th.muls	a1,t6,a5
    3ca6:	0ff5fa93          	zext.b	s5,a1
    3caa:	030a839b          	addiw	t2,s5,48
    3cae:	015b073b          	addw	a4,s6,s5
    3cb2:	0ff3ff13          	zext.b	t5,t2
    3cb6:	0ff77a93          	zext.b	s5,a4
    3cba:	00bcb2b3          	sltu	t0,s9,a1
    3cbe:	405f1a8b          	th.mveqz	s5,t5,t0
    3cc2:	01550123          	sb	s5,2(a0)
    3cc6:	00f37463          	bgeu	t1,a5,3cce <_vsnprintf+0x13be>
    3cca:	6c20106f          	j	538c <_vsnprintf+0x2a7c>
    3cce:	02ffd2b3          	divu	t0,t6,a5
    3cd2:	837e                	mv	t1,t6
    3cd4:	00350613          	addi	a2,a0,3
    3cd8:	22f2930b          	th.muls	t1,t0,a5
    3cdc:	0ff37593          	zext.b	a1,t1
    3ce0:	0305839b          	addiw	t2,a1,48
    3ce4:	00bb073b          	addw	a4,s6,a1
    3ce8:	0ff3ff13          	zext.b	t5,t2
    3cec:	0ff77a93          	zext.b	s5,a4
    3cf0:	006cb333          	sltu	t1,s9,t1
    3cf4:	406f1a8b          	th.mveqz	s5,t5,t1
    3cf8:	015501a3          	sb	s5,3(a0)
    3cfc:	00fff463          	bgeu	t6,a5,3d04 <_vsnprintf+0x13f4>
    3d00:	68c0106f          	j	538c <_vsnprintf+0x2a7c>
    3d04:	00450613          	addi	a2,a0,4
    3d08:	b5e5                	j	3bf0 <_vsnprintf+0x12e0>
    3d0a:	05800613          	li	a2,88
    3d0e:	76c50f63          	beq	a0,a2,448c <_vsnprintf+0x1b7c>
    3d12:	4789                	li	a5,2
    3d14:	06200313          	li	t1,98
    3d18:	86be                	mv	a3,a5
    3d1a:	e26507e3          	beq	a0,t1,3b48 <_vsnprintf+0x1238>
    3d1e:	400b7693          	andi	a3,s6,1024
    3d22:	2a069ee3          	bnez	a3,47de <_vsnprintf+0x1ece>
    3d26:	fefb7793          	andi	a5,s6,-17
    3d2a:	200b7393          	andi	t2,s6,512
    3d2e:	0007859b          	sext.w	a1,a5
    3d32:	00038463          	beqz	t2,3d3a <_vsnprintf+0x142a>
    3d36:	0fe0206f          	j	5e34 <_vsnprintf+0x3524>
    3d3a:	100b7e93          	andi	t4,s6,256
    3d3e:	2c0e81e3          	beqz	t4,4800 <_vsnprintf+0x1ef0>
    3d42:	886e                	mv	a6,s11
    3d44:	78884e0b          	th.ldia	t3,(a6),8,0
    3d48:	4501                	li	a0,0
    3d4a:	000e0863          	beqz	t3,3d5a <_vsnprintf+0x144a>
    3d4e:	43fe5d93          	srai	s11,t3,0x3f
    3d52:	01cdc6b3          	xor	a3,s11,t3
    3d56:	41b68533          	sub	a0,a3,s11
    3d5a:	42a9                	li	t0,10
    3d5c:	025573b3          	remu	t2,a0,t0
    3d60:	03010313          	addi	t1,sp,48
    3d64:	4ca5                	li	s9,9
    3d66:	879a                	mv	a5,t1
    3d68:	03038f1b          	addiw	t5,t2,48
    3d6c:	03e10823          	sb	t5,48(sp)
    3d70:	02555733          	divu	a4,a0,t0
    3d74:	10acf963          	bgeu	s9,a0,3e86 <_vsnprintf+0x1576>
    3d78:	03110793          	addi	a5,sp,49
    3d7c:	02577fb3          	remu	t6,a4,t0
    3d80:	030f8e9b          	addiw	t4,t6,48
    3d84:	01d78023          	sb	t4,0(a5)
    3d88:	02575d33          	divu	s10,a4,t0
    3d8c:	0eecfd63          	bgeu	s9,a4,3e86 <_vsnprintf+0x1576>
    3d90:	00178b93          	addi	s7,a5,1
    3d94:	05010b13          	addi	s6,sp,80
    3d98:	0f7b0763          	beq	s6,s7,3e86 <_vsnprintf+0x1576>
    3d9c:	87de                	mv	a5,s7
    3d9e:	025d7ab3          	remu	s5,s10,t0
    3da2:	030a861b          	addiw	a2,s5,48
    3da6:	00cb8023          	sb	a2,0(s7)
    3daa:	025d5733          	divu	a4,s10,t0
    3dae:	0dacfc63          	bgeu	s9,s10,3e86 <_vsnprintf+0x1576>
    3db2:	02577fb3          	remu	t6,a4,t0
    3db6:	030f8d9b          	addiw	s11,t6,48
    3dba:	0817dd8b          	th.sbib	s11,(a5),1,0
    3dbe:	025756b3          	divu	a3,a4,t0
    3dc2:	0cecf263          	bgeu	s9,a4,3e86 <_vsnprintf+0x1576>
    3dc6:	002b8793          	addi	a5,s7,2
    3dca:	0256f533          	remu	a0,a3,t0
    3dce:	0305039b          	addiw	t2,a0,48
    3dd2:	007b8123          	sb	t2,2(s7)
    3dd6:	0256df33          	divu	t5,a3,t0
    3dda:	0adcf663          	bgeu	s9,a3,3e86 <_vsnprintf+0x1576>
    3dde:	003b8793          	addi	a5,s7,3
    3de2:	025f7eb3          	remu	t4,t5,t0
    3de6:	030e8d1b          	addiw	s10,t4,48
    3dea:	01ab81a3          	sb	s10,3(s7)
    3dee:	025f5b33          	divu	s6,t5,t0
    3df2:	09ecfa63          	bgeu	s9,t5,3e86 <_vsnprintf+0x1576>
    3df6:	004b8793          	addi	a5,s7,4
    3dfa:	025b7ab3          	remu	s5,s6,t0
    3dfe:	030a861b          	addiw	a2,s5,48
    3e02:	00cb8223          	sb	a2,4(s7)
    3e06:	025b5733          	divu	a4,s6,t0
    3e0a:	076cfe63          	bgeu	s9,s6,3e86 <_vsnprintf+0x1576>
    3e0e:	005b8793          	addi	a5,s7,5
    3e12:	02577fb3          	remu	t6,a4,t0
    3e16:	030f8d9b          	addiw	s11,t6,48
    3e1a:	01bb82a3          	sb	s11,5(s7)
    3e1e:	025756b3          	divu	a3,a4,t0
    3e22:	06ecf263          	bgeu	s9,a4,3e86 <_vsnprintf+0x1576>
    3e26:	006b8793          	addi	a5,s7,6
    3e2a:	0256f533          	remu	a0,a3,t0
    3e2e:	0305039b          	addiw	t2,a0,48
    3e32:	007b8323          	sb	t2,6(s7)
    3e36:	0256deb3          	divu	t4,a3,t0
    3e3a:	04dcf663          	bgeu	s9,a3,3e86 <_vsnprintf+0x1576>
    3e3e:	007b8793          	addi	a5,s7,7
    3e42:	025eff33          	remu	t5,t4,t0
    3e46:	030f0d1b          	addiw	s10,t5,48
    3e4a:	01ab83a3          	sb	s10,7(s7)
    3e4e:	025edb33          	divu	s6,t4,t0
    3e52:	03dcfa63          	bgeu	s9,t4,3e86 <_vsnprintf+0x1576>
    3e56:	008b8793          	addi	a5,s7,8
    3e5a:	025b7ab3          	remu	s5,s6,t0
    3e5e:	030a861b          	addiw	a2,s5,48
    3e62:	00cb8423          	sb	a2,8(s7)
    3e66:	025b5733          	divu	a4,s6,t0
    3e6a:	016cfe63          	bgeu	s9,s6,3e86 <_vsnprintf+0x1576>
    3e6e:	009b8793          	addi	a5,s7,9
    3e72:	02577fb3          	remu	t6,a4,t0
    3e76:	030f8e9b          	addiw	t4,t6,48
    3e7a:	01d78023          	sb	t4,0(a5)
    3e7e:	02575d33          	divu	s10,a4,t0
    3e82:	f0ece7e3          	bltu	s9,a4,3d90 <_vsnprintf+0x1480>
    3e86:	406787b3          	sub	a5,a5,t1
    3e8a:	0025fb13          	andi	s6,a1,2
    3e8e:	0785                	addi	a5,a5,1
    3e90:	82ae                	mv	t0,a1
    3e92:	000b1463          	bnez	s6,3e9a <_vsnprintf+0x158a>
    3e96:	4200306f          	j	72b6 <_vsnprintf+0x49a6>
    3e9a:	02000c13          	li	s8,32
    3e9e:	4b09                	li	s6,2
    3ea0:	01878463          	beq	a5,s8,3ea8 <_vsnprintf+0x1598>
    3ea4:	6190306f          	j	7cbc <_vsnprintf+0x53ac>
    3ea8:	04f14503          	lbu	a0,79(sp)
    3eac:	6382                	ld	t2,0(sp)
    3eae:	8dc2                	mv	s11,a6
    3eb0:	02000d13          	li	s10,32
    3eb4:	01a30c33          	add	s8,t1,s10
    3eb8:	fff34813          	not	a6,t1
    3ebc:	018802b3          	add	t0,a6,s8
    3ec0:	01a38cb3          	add	s9,t2,s10
    3ec4:	0072fd13          	andi	s10,t0,7
    3ec8:	01930bb3          	add	s7,t1,s9
    3ecc:	000d1463          	bnez	s10,3ed4 <_vsnprintf+0x15c4>
    3ed0:	5910306f          	j	7c60 <_vsnprintf+0x5350>
    3ed4:	418b8633          	sub	a2,s7,s8
    3ed8:	ec46                	sd	a7,24(sp)
    3eda:	f01a                	sd	t1,32(sp)
    3edc:	86a6                	mv	a3,s1
    3ede:	85ca                	mv	a1,s2
    3ee0:	9402                	jalr	s0
    3ee2:	4f85                	li	t6,1
    3ee4:	68e2                	ld	a7,24(sp)
    3ee6:	7302                	ld	t1,32(sp)
    3ee8:	1c7d                	addi	s8,s8,-1
    3eea:	fffc4503          	lbu	a0,-1(s8)
    3eee:	01fd1463          	bne	s10,t6,3ef6 <_vsnprintf+0x15e6>
    3ef2:	56f0306f          	j	7c60 <_vsnprintf+0x5350>
    3ef6:	4389                	li	t2,2
    3ef8:	087d0863          	beq	s10,t2,3f88 <_vsnprintf+0x1678>
    3efc:	470d                	li	a4,3
    3efe:	06ed0963          	beq	s10,a4,3f70 <_vsnprintf+0x1660>
    3f02:	4a91                	li	s5,4
    3f04:	055d0a63          	beq	s10,s5,3f58 <_vsnprintf+0x1648>
    3f08:	4e95                	li	t4,5
    3f0a:	03dd0b63          	beq	s10,t4,3f40 <_vsnprintf+0x1630>
    3f0e:	4f19                	li	t5,6
    3f10:	01ed0c63          	beq	s10,t5,3f28 <_vsnprintf+0x1618>
    3f14:	418b8633          	sub	a2,s7,s8
    3f18:	86a6                	mv	a3,s1
    3f1a:	85ca                	mv	a1,s2
    3f1c:	9402                	jalr	s0
    3f1e:	68e2                	ld	a7,24(sp)
    3f20:	7302                	ld	t1,32(sp)
    3f22:	ffec4503          	lbu	a0,-2(s8)
    3f26:	1c7d                	addi	s8,s8,-1
    3f28:	ec46                	sd	a7,24(sp)
    3f2a:	f01a                	sd	t1,32(sp)
    3f2c:	418b8633          	sub	a2,s7,s8
    3f30:	86a6                	mv	a3,s1
    3f32:	85ca                	mv	a1,s2
    3f34:	9402                	jalr	s0
    3f36:	68e2                	ld	a7,24(sp)
    3f38:	7302                	ld	t1,32(sp)
    3f3a:	ffec4503          	lbu	a0,-2(s8)
    3f3e:	1c7d                	addi	s8,s8,-1
    3f40:	ec46                	sd	a7,24(sp)
    3f42:	f01a                	sd	t1,32(sp)
    3f44:	418b8633          	sub	a2,s7,s8
    3f48:	86a6                	mv	a3,s1
    3f4a:	85ca                	mv	a1,s2
    3f4c:	9402                	jalr	s0
    3f4e:	68e2                	ld	a7,24(sp)
    3f50:	7302                	ld	t1,32(sp)
    3f52:	ffec4503          	lbu	a0,-2(s8)
    3f56:	1c7d                	addi	s8,s8,-1
    3f58:	ec46                	sd	a7,24(sp)
    3f5a:	f01a                	sd	t1,32(sp)
    3f5c:	418b8633          	sub	a2,s7,s8
    3f60:	86a6                	mv	a3,s1
    3f62:	85ca                	mv	a1,s2
    3f64:	9402                	jalr	s0
    3f66:	68e2                	ld	a7,24(sp)
    3f68:	7302                	ld	t1,32(sp)
    3f6a:	ffec4503          	lbu	a0,-2(s8)
    3f6e:	1c7d                	addi	s8,s8,-1
    3f70:	ec46                	sd	a7,24(sp)
    3f72:	f01a                	sd	t1,32(sp)
    3f74:	418b8633          	sub	a2,s7,s8
    3f78:	86a6                	mv	a3,s1
    3f7a:	85ca                	mv	a1,s2
    3f7c:	9402                	jalr	s0
    3f7e:	68e2                	ld	a7,24(sp)
    3f80:	7302                	ld	t1,32(sp)
    3f82:	ffec4503          	lbu	a0,-2(s8)
    3f86:	1c7d                	addi	s8,s8,-1
    3f88:	418b8633          	sub	a2,s7,s8
    3f8c:	ec46                	sd	a7,24(sp)
    3f8e:	f01a                	sd	t1,32(sp)
    3f90:	86a6                	mv	a3,s1
    3f92:	85ca                	mv	a1,s2
    3f94:	9402                	jalr	s0
    3f96:	1c7d                	addi	s8,s8,-1
    3f98:	6d62                	ld	s10,24(sp)
    3f9a:	7a82                	ld	s5,32(sp)
    3f9c:	fffc4503          	lbu	a0,-1(s8)
    3fa0:	a071                	j	402c <_vsnprintf+0x171c>
    3fa2:	87e2                	mv	a5,s8
    3fa4:	40ab8633          	sub	a2,s7,a0
    3fa8:	89e7c50b          	th.lbuib	a0,(a5),-2,0
    3fac:	86a6                	mv	a3,s1
    3fae:	85ca                	mv	a1,s2
    3fb0:	ec3e                	sd	a5,24(sp)
    3fb2:	9402                	jalr	s0
    3fb4:	8e62                	mv	t3,s8
    3fb6:	89de450b          	th.lbuib	a0,(t3),-3,0
    3fba:	6662                	ld	a2,24(sp)
    3fbc:	86a6                	mv	a3,s1
    3fbe:	ec72                	sd	t3,24(sp)
    3fc0:	85ca                	mv	a1,s2
    3fc2:	40cb8633          	sub	a2,s7,a2
    3fc6:	9402                	jalr	s0
    3fc8:	8862                	mv	a6,s8
    3fca:	89c8450b          	th.lbuib	a0,(a6),-4,0
    3fce:	62e2                	ld	t0,24(sp)
    3fd0:	86a6                	mv	a3,s1
    3fd2:	ec42                	sd	a6,24(sp)
    3fd4:	405b8633          	sub	a2,s7,t0
    3fd8:	85ca                	mv	a1,s2
    3fda:	9402                	jalr	s0
    3fdc:	8fe2                	mv	t6,s8
    3fde:	89bfc50b          	th.lbuib	a0,(t6),-5,0
    3fe2:	63e2                	ld	t2,24(sp)
    3fe4:	86a6                	mv	a3,s1
    3fe6:	ec7e                	sd	t6,24(sp)
    3fe8:	407b8633          	sub	a2,s7,t2
    3fec:	85ca                	mv	a1,s2
    3fee:	9402                	jalr	s0
    3ff0:	8762                	mv	a4,s8
    3ff2:	89a7450b          	th.lbuib	a0,(a4),-6,0
    3ff6:	6ee2                	ld	t4,24(sp)
    3ff8:	86a6                	mv	a3,s1
    3ffa:	ec3a                	sd	a4,24(sp)
    3ffc:	41db8633          	sub	a2,s7,t4
    4000:	85ca                	mv	a1,s2
    4002:	9402                	jalr	s0
    4004:	8f62                	mv	t5,s8
    4006:	899f450b          	th.lbuib	a0,(t5),-7,0
    400a:	6362                	ld	t1,24(sp)
    400c:	86a6                	mv	a3,s1
    400e:	85ca                	mv	a1,s2
    4010:	406b8633          	sub	a2,s7,t1
    4014:	ec7a                	sd	t5,24(sp)
    4016:	9402                	jalr	s0
    4018:	68e2                	ld	a7,24(sp)
    401a:	898c450b          	th.lbuib	a0,(s8),-8,0
    401e:	86a6                	mv	a3,s1
    4020:	85ca                	mv	a1,s2
    4022:	411b8633          	sub	a2,s7,a7
    4026:	9402                	jalr	s0
    4028:	fffc4503          	lbu	a0,-1(s8)
    402c:	86a6                	mv	a3,s1
    402e:	418b8633          	sub	a2,s7,s8
    4032:	85ca                	mv	a1,s2
    4034:	ec66                	sd	s9,24(sp)
    4036:	9402                	jalr	s0
    4038:	fffc0513          	addi	a0,s8,-1
    403c:	6e62                	ld	t3,24(sp)
    403e:	f6aa92e3          	bne	s5,a0,3fa2 <_vsnprintf+0x1692>
    4042:	88ea                	mv	a7,s10
    4044:	180b0463          	beqz	s6,41cc <_vsnprintf+0x18bc>
    4048:	6b02                	ld	s6,0(sp)
    404a:	7c08bb8b          	th.extu	s7,a7,31,0
    404e:	416e0cb3          	sub	s9,t3,s6
    4052:	177cfd63          	bgeu	s9,s7,41cc <_vsnprintf+0x18bc>
    4056:	fffcc793          	not	a5,s9
    405a:	01778633          	add	a2,a5,s7
    405e:	00767d13          	andi	s10,a2,7
    4062:	8672                	mv	a2,t3
    4064:	0e05                	addi	t3,t3,1
    4066:	e072                	sd	t3,0(sp)
    4068:	86a6                	mv	a3,s1
    406a:	85ca                	mv	a1,s2
    406c:	02000513          	li	a0,32
    4070:	9402                	jalr	s0
    4072:	001c8c13          	addi	s8,s9,1
    4076:	6e02                	ld	t3,0(sp)
    4078:	157c7a63          	bgeu	s8,s7,41cc <_vsnprintf+0x18bc>
    407c:	0c0d0463          	beqz	s10,4144 <_vsnprintf+0x1834>
    4080:	4585                	li	a1,1
    4082:	0abd0463          	beq	s10,a1,412a <_vsnprintf+0x181a>
    4086:	4689                	li	a3,2
    4088:	08dd0663          	beq	s10,a3,4114 <_vsnprintf+0x1804>
    408c:	480d                	li	a6,3
    408e:	070d0863          	beq	s10,a6,40fe <_vsnprintf+0x17ee>
    4092:	4291                	li	t0,4
    4094:	045d0a63          	beq	s10,t0,40e8 <_vsnprintf+0x17d8>
    4098:	4f95                	li	t6,5
    409a:	03fd0c63          	beq	s10,t6,40d2 <_vsnprintf+0x17c2>
    409e:	4399                	li	t2,6
    40a0:	007d0e63          	beq	s10,t2,40bc <_vsnprintf+0x17ac>
    40a4:	001e0713          	addi	a4,t3,1
    40a8:	8672                	mv	a2,t3
    40aa:	86a6                	mv	a3,s1
    40ac:	85ca                	mv	a1,s2
    40ae:	02000513          	li	a0,32
    40b2:	e03a                	sd	a4,0(sp)
    40b4:	9402                	jalr	s0
    40b6:	6e02                	ld	t3,0(sp)
    40b8:	002c8c13          	addi	s8,s9,2
    40bc:	001e0e93          	addi	t4,t3,1
    40c0:	8672                	mv	a2,t3
    40c2:	86a6                	mv	a3,s1
    40c4:	85ca                	mv	a1,s2
    40c6:	02000513          	li	a0,32
    40ca:	e076                	sd	t4,0(sp)
    40cc:	9402                	jalr	s0
    40ce:	6e02                	ld	t3,0(sp)
    40d0:	0c05                	addi	s8,s8,1
    40d2:	001e0f13          	addi	t5,t3,1
    40d6:	8672                	mv	a2,t3
    40d8:	86a6                	mv	a3,s1
    40da:	85ca                	mv	a1,s2
    40dc:	02000513          	li	a0,32
    40e0:	e07a                	sd	t5,0(sp)
    40e2:	9402                	jalr	s0
    40e4:	6e02                	ld	t3,0(sp)
    40e6:	0c05                	addi	s8,s8,1
    40e8:	001e0313          	addi	t1,t3,1
    40ec:	8672                	mv	a2,t3
    40ee:	86a6                	mv	a3,s1
    40f0:	85ca                	mv	a1,s2
    40f2:	02000513          	li	a0,32
    40f6:	e01a                	sd	t1,0(sp)
    40f8:	9402                	jalr	s0
    40fa:	6e02                	ld	t3,0(sp)
    40fc:	0c05                	addi	s8,s8,1
    40fe:	001e0a93          	addi	s5,t3,1
    4102:	8672                	mv	a2,t3
    4104:	86a6                	mv	a3,s1
    4106:	85ca                	mv	a1,s2
    4108:	02000513          	li	a0,32
    410c:	e056                	sd	s5,0(sp)
    410e:	9402                	jalr	s0
    4110:	6e02                	ld	t3,0(sp)
    4112:	0c05                	addi	s8,s8,1
    4114:	001e0893          	addi	a7,t3,1
    4118:	8672                	mv	a2,t3
    411a:	86a6                	mv	a3,s1
    411c:	85ca                	mv	a1,s2
    411e:	02000513          	li	a0,32
    4122:	e046                	sd	a7,0(sp)
    4124:	9402                	jalr	s0
    4126:	6e02                	ld	t3,0(sp)
    4128:	0c05                	addi	s8,s8,1
    412a:	001e0b13          	addi	s6,t3,1
    412e:	8672                	mv	a2,t3
    4130:	86a6                	mv	a3,s1
    4132:	85ca                	mv	a1,s2
    4134:	02000513          	li	a0,32
    4138:	e05a                	sd	s6,0(sp)
    413a:	9402                	jalr	s0
    413c:	0c05                	addi	s8,s8,1
    413e:	6e02                	ld	t3,0(sp)
    4140:	097c7663          	bgeu	s8,s7,41cc <_vsnprintf+0x18bc>
    4144:	8af2                	mv	s5,t3
    4146:	8656                	mv	a2,s5
    4148:	86a6                	mv	a3,s1
    414a:	85ca                	mv	a1,s2
    414c:	02000513          	li	a0,32
    4150:	9402                	jalr	s0
    4152:	001a8d13          	addi	s10,s5,1
    4156:	866a                	mv	a2,s10
    4158:	86a6                	mv	a3,s1
    415a:	85ca                	mv	a1,s2
    415c:	02000513          	li	a0,32
    4160:	9402                	jalr	s0
    4162:	002a8c93          	addi	s9,s5,2
    4166:	8666                	mv	a2,s9
    4168:	86a6                	mv	a3,s1
    416a:	85ca                	mv	a1,s2
    416c:	02000513          	li	a0,32
    4170:	9402                	jalr	s0
    4172:	003a8b13          	addi	s6,s5,3
    4176:	865a                	mv	a2,s6
    4178:	86a6                	mv	a3,s1
    417a:	85ca                	mv	a1,s2
    417c:	02000513          	li	a0,32
    4180:	9402                	jalr	s0
    4182:	004a8d13          	addi	s10,s5,4
    4186:	866a                	mv	a2,s10
    4188:	86a6                	mv	a3,s1
    418a:	85ca                	mv	a1,s2
    418c:	02000513          	li	a0,32
    4190:	9402                	jalr	s0
    4192:	005a8b13          	addi	s6,s5,5
    4196:	86a6                	mv	a3,s1
    4198:	865a                	mv	a2,s6
    419a:	85ca                	mv	a1,s2
    419c:	02000513          	li	a0,32
    41a0:	9402                	jalr	s0
    41a2:	006a8c93          	addi	s9,s5,6
    41a6:	86a6                	mv	a3,s1
    41a8:	8666                	mv	a2,s9
    41aa:	85ca                	mv	a1,s2
    41ac:	02000513          	li	a0,32
    41b0:	9402                	jalr	s0
    41b2:	007a8d13          	addi	s10,s5,7
    41b6:	86a6                	mv	a3,s1
    41b8:	866a                	mv	a2,s10
    41ba:	85ca                	mv	a1,s2
    41bc:	02000513          	li	a0,32
    41c0:	0c21                	addi	s8,s8,8
    41c2:	0aa1                	addi	s5,s5,8
    41c4:	9402                	jalr	s0
    41c6:	f97c60e3          	bltu	s8,s7,4146 <_vsnprintf+0x1836>
    41ca:	8e56                	mv	t3,s5
    41cc:	e072                	sd	t3,0(sp)
    41ce:	a829                	j	41e8 <_vsnprintf+0x18d8>
    41d0:	6602                	ld	a2,0(sp)
    41d2:	988dc50b          	th.lbuia	a0,(s11),8,0
    41d6:	86a6                	mv	a3,s1
    41d8:	85ca                	mv	a1,s2
    41da:	00160b13          	addi	s6,a2,1
    41de:	9402                	jalr	s0
    41e0:	e05a                	sd	s6,0(sp)
    41e2:	0001                	nop
    41e4:	00000013          	nop
    41e8:	63a2                	ld	t2,8(sp)
    41ea:	00138c93          	addi	s9,t2,1
    41ee:	f82fe06f          	j	2970 <_vsnprintf+0x60>
    41f2:	88ea                	mv	a7,s10
    41f4:	8d66                	mv	s10,s9
    41f6:	e06a                	sd	s10,0(sp)
    41f8:	fe0a88e3          	beqz	s5,41e8 <_vsnprintf+0x18d8>
    41fc:	ea7fe06f          	j	30a2 <_vsnprintf+0x792>
    4200:	0025f893          	andi	a7,a1,2
    4204:	852e                	mv	a0,a1
    4206:	56089d63          	bnez	a7,4780 <_vsnprintf+0x1e70>
    420a:	00c5fe13          	andi	t3,a1,12
    420e:	3a0e1ae3          	bnez	t3,4dc2 <_vsnprintf+0x24b2>
    4212:	47c1                	li	a5,16
    4214:	8abe                	mv	s5,a5
    4216:	7c0c3f8b          	th.extu	t6,s8,31,0
    421a:	29fd62e3          	bltu	s10,t6,4c9e <_vsnprintf+0x238e>
    421e:	00fd6463          	bltu	s10,a5,4226 <_vsnprintf+0x1916>
    4222:	3730206f          	j	6d94 <_vsnprintf+0x4484>
    4226:	03000c13          	li	s8,48
    422a:	018103b3          	add	t2,sp,s8
    422e:	007d0833          	add	a6,s10,t2
    4232:	001d0e13          	addi	t3,s10,1
    4236:	01880023          	sb	s8,0(a6)
    423a:	00fe6463          	bltu	t3,a5,4242 <_vsnprintf+0x1932>
    423e:	52d0306f          	j	7f6a <_vsnprintf+0x565a>
    4242:	9e0a                	add	t3,t3,sp
    4244:	03000313          	li	t1,48
    4248:	002d0e93          	addi	t4,s10,2
    424c:	026e0823          	sb	t1,48(t3)
    4250:	70fefae3          	bgeu	t4,a5,5164 <_vsnprintf+0x2854>
    4254:	00610533          	add	a0,sp,t1
    4258:	00ad0c33          	add	s8,s10,a0
    425c:	003d0f13          	addi	t5,s10,3
    4260:	006c0123          	sb	t1,2(s8)
    4264:	70ff70e3          	bgeu	t5,a5,5164 <_vsnprintf+0x2854>
    4268:	00ad0833          	add	a6,s10,a0
    426c:	004d0613          	addi	a2,s10,4
    4270:	006801a3          	sb	t1,3(a6)
    4274:	6ef678e3          	bgeu	a2,a5,5164 <_vsnprintf+0x2854>
    4278:	00ad0733          	add	a4,s10,a0
    427c:	005d0293          	addi	t0,s10,5
    4280:	00670223          	sb	t1,4(a4)
    4284:	6ef2f0e3          	bgeu	t0,a5,5164 <_vsnprintf+0x2854>
    4288:	00ad0f33          	add	t5,s10,a0
    428c:	006d0e13          	addi	t3,s10,6
    4290:	006f02a3          	sb	t1,5(t5)
    4294:	6cfe78e3          	bgeu	t3,a5,5164 <_vsnprintf+0x2854>
    4298:	00ad0633          	add	a2,s10,a0
    429c:	007d0893          	addi	a7,s10,7
    42a0:	00660323          	sb	t1,6(a2)
    42a4:	6cf8f0e3          	bgeu	a7,a5,5164 <_vsnprintf+0x2854>
    42a8:	00ad02b3          	add	t0,s10,a0
    42ac:	008d0393          	addi	t2,s10,8
    42b0:	006283a3          	sb	t1,7(t0)
    42b4:	6af3f8e3          	bgeu	t2,a5,5164 <_vsnprintf+0x2854>
    42b8:	00ad0e33          	add	t3,s10,a0
    42bc:	009d0e93          	addi	t4,s10,9
    42c0:	006e0423          	sb	t1,8(t3)
    42c4:	6afef0e3          	bgeu	t4,a5,5164 <_vsnprintf+0x2854>
    42c8:	00ad08b3          	add	a7,s10,a0
    42cc:	00ad0f13          	addi	t5,s10,10
    42d0:	006884a3          	sb	t1,9(a7)
    42d4:	68ff78e3          	bgeu	t5,a5,5164 <_vsnprintf+0x2854>
    42d8:	00ad03b3          	add	t2,s10,a0
    42dc:	00bd0c13          	addi	s8,s10,11
    42e0:	00638523          	sb	t1,10(t2)
    42e4:	68fc70e3          	bgeu	s8,a5,5164 <_vsnprintf+0x2854>
    42e8:	00ad0eb3          	add	t4,s10,a0
    42ec:	03000713          	li	a4,48
    42f0:	00cd0313          	addi	t1,s10,12
    42f4:	00ee85a3          	sb	a4,11(t4)
    42f8:	66f376e3          	bgeu	t1,a5,5164 <_vsnprintf+0x2854>
    42fc:	00ad06b3          	add	a3,s10,a0
    4300:	00dd0e13          	addi	t3,s10,13
    4304:	00e68623          	sb	a4,12(a3)
    4308:	64fe7ee3          	bgeu	t3,a5,5164 <_vsnprintf+0x2854>
    430c:	00ad0633          	add	a2,s10,a0
    4310:	00ed0893          	addi	a7,s10,14
    4314:	00e606a3          	sb	a4,13(a2)
    4318:	64f8f6e3          	bgeu	a7,a5,5164 <_vsnprintf+0x2854>
    431c:	00ad0333          	add	t1,s10,a0
    4320:	01a03d33          	snez	s10,s10
    4324:	00e30723          	sb	a4,14(t1)
    4328:	00fd0813          	addi	a6,s10,15
    432c:	62f87ce3          	bgeu	a6,a5,5164 <_vsnprintf+0x2854>
    4330:	02e10fa3          	sb	a4,63(sp)
    4334:	000b8463          	beqz	s7,433c <_vsnprintf+0x1a2c>
    4338:	3620106f          	j	569a <_vsnprintf+0x2d8a>
    433c:	0045fe13          	andi	t3,a1,4
    4340:	000e0463          	beqz	t3,4348 <_vsnprintf+0x1a38>
    4344:	10e0306f          	j	7452 <_vsnprintf+0x4b42>
    4348:	0085fb93          	andi	s7,a1,8
    434c:	000b8463          	beqz	s7,4354 <_vsnprintf+0x1a44>
    4350:	1650306f          	j	7cb4 <_vsnprintf+0x53a4>
    4354:	4d41                	li	s10,16
    4356:	06010f93          	addi	t6,sp,96
    435a:	fdffc503          	lbu	a0,-33(t6)
    435e:	a47d                	j	460c <_vsnprintf+0x1cfc>
    4360:	885a                	mv	a6,s6
    4362:	87c6                	mv	a5,a7
    4364:	8762                	mv	a4,s8
    4366:	6602                	ld	a2,0(sp)
    4368:	86a6                	mv	a3,s1
    436a:	85ca                	mv	a1,s2
    436c:	8522                	mv	a0,s0
    436e:	b13fc0ef          	jal	e80 <_ftoa>
    4372:	e02a                	sd	a0,0(sp)
    4374:	6622                	ld	a2,8(sp)
    4376:	8dde                	mv	s11,s7
    4378:	00160c93          	addi	s9,a2,1
    437c:	df4fe06f          	j	2970 <_vsnprintf+0x60>
    4380:	6505                	lui	a0,0x1
    4382:	80050813          	addi	a6,a0,-2048 # 800 <Proc_5>
    4386:	010b62b3          	or	t0,s6,a6
    438a:	00028b1b          	sext.w	s6,t0
    438e:	020b6313          	ori	t1,s6,32
    4392:	00030b1b          	sext.w	s6,t1
    4396:	ed3fe06f          	j	3268 <_vsnprintf+0x958>
    439a:	400b7793          	andi	a5,s6,1024
    439e:	41ac8bbb          	subw	s7,s9,s10
    43a2:	c399                	beqz	a5,43a8 <_vsnprintf+0x1a98>
    43a4:	b17fe06f          	j	2eba <_vsnprintf+0x5aa>
    43a8:	002b7b13          	andi	s6,s6,2
    43ac:	000b1463          	bnez	s6,43b4 <_vsnprintf+0x1aa4>
    43b0:	4b20106f          	j	5862 <_vsnprintf+0x2f52>
    43b4:	6c82                	ld	s9,0(sp)
    43b6:	4a89                	li	s5,2
    43b8:	8b66                	mv	s6,s9
    43ba:	419d0d33          	sub	s10,s10,s9
    43be:	8cc6                	mv	s9,a7
    43c0:	865a                	mv	a2,s6
    43c2:	86a6                	mv	a3,s1
    43c4:	85ca                	mv	a1,s2
    43c6:	0b05                	addi	s6,s6,1
    43c8:	9402                	jalr	s0
    43ca:	816d450b          	th.lrbu	a0,s10,s6,0
    43ce:	8c5a                	mv	s8,s6
    43d0:	cd3d                	beqz	a0,444e <_vsnprintf+0x1b3e>
    43d2:	86a6                	mv	a3,s1
    43d4:	8662                	mv	a2,s8
    43d6:	85ca                	mv	a1,s2
    43d8:	0b05                	addi	s6,s6,1
    43da:	9402                	jalr	s0
    43dc:	816d450b          	th.lrbu	a0,s10,s6,0
    43e0:	c53d                	beqz	a0,444e <_vsnprintf+0x1b3e>
    43e2:	865a                	mv	a2,s6
    43e4:	86a6                	mv	a3,s1
    43e6:	85ca                	mv	a1,s2
    43e8:	002c0b13          	addi	s6,s8,2
    43ec:	9402                	jalr	s0
    43ee:	816d450b          	th.lrbu	a0,s10,s6,0
    43f2:	cd31                	beqz	a0,444e <_vsnprintf+0x1b3e>
    43f4:	865a                	mv	a2,s6
    43f6:	86a6                	mv	a3,s1
    43f8:	85ca                	mv	a1,s2
    43fa:	003c0b13          	addi	s6,s8,3
    43fe:	9402                	jalr	s0
    4400:	816d450b          	th.lrbu	a0,s10,s6,0
    4404:	c529                	beqz	a0,444e <_vsnprintf+0x1b3e>
    4406:	865a                	mv	a2,s6
    4408:	86a6                	mv	a3,s1
    440a:	85ca                	mv	a1,s2
    440c:	004c0b13          	addi	s6,s8,4
    4410:	9402                	jalr	s0
    4412:	816d450b          	th.lrbu	a0,s10,s6,0
    4416:	cd05                	beqz	a0,444e <_vsnprintf+0x1b3e>
    4418:	865a                	mv	a2,s6
    441a:	86a6                	mv	a3,s1
    441c:	85ca                	mv	a1,s2
    441e:	005c0b13          	addi	s6,s8,5
    4422:	9402                	jalr	s0
    4424:	816d450b          	th.lrbu	a0,s10,s6,0
    4428:	c11d                	beqz	a0,444e <_vsnprintf+0x1b3e>
    442a:	865a                	mv	a2,s6
    442c:	86a6                	mv	a3,s1
    442e:	85ca                	mv	a1,s2
    4430:	006c0b13          	addi	s6,s8,6
    4434:	9402                	jalr	s0
    4436:	816d450b          	th.lrbu	a0,s10,s6,0
    443a:	c911                	beqz	a0,444e <_vsnprintf+0x1b3e>
    443c:	865a                	mv	a2,s6
    443e:	86a6                	mv	a3,s1
    4440:	85ca                	mv	a1,s2
    4442:	007c0b13          	addi	s6,s8,7
    4446:	9402                	jalr	s0
    4448:	816d450b          	th.lrbu	a0,s10,s6,0
    444c:	f935                	bnez	a0,43c0 <_vsnprintf+0x1ab0>
    444e:	e05a                	sd	s6,0(sp)
    4450:	88e6                	mv	a7,s9
    4452:	d80a8be3          	beqz	s5,41e8 <_vsnprintf+0x18d8>
    4456:	c4dfe06f          	j	30a2 <_vsnprintf+0x792>
    445a:	0c0b6813          	ori	a6,s6,192
    445e:	00278f93          	addi	t6,a5,2
    4462:	0027c503          	lbu	a0,2(a5)
    4466:	00080b1b          	sext.w	s6,a6
    446a:	e47e                	sd	t6,8(sp)
    446c:	dc4fe06f          	j	2a30 <_vsnprintf+0x120>
    4470:	300b6513          	ori	a0,s6,768
    4474:	002e0293          	addi	t0,t3,2
    4478:	00050b1b          	sext.w	s6,a0
    447c:	e416                	sd	t0,8(sp)
    447e:	002e4503          	lbu	a0,2(t3)
    4482:	daefe06f          	j	2a30 <_vsnprintf+0x120>
    4486:	4981                	li	s3,0
    4488:	ec6fe06f          	j	2b4e <_vsnprintf+0x23e>
    448c:	020b6393          	ori	t2,s6,32
    4490:	47c1                	li	a5,16
    4492:	00038b1b          	sext.w	s6,t2
    4496:	86be                	mv	a3,a5
    4498:	eb0ff06f          	j	3b48 <_vsnprintf+0x1238>
    449c:	4385                	li	t2,1
    449e:	d313f9e3          	bgeu	t2,a7,41d0 <_vsnprintf+0x18c0>
    44a2:	6302                	ld	t1,0(sp)
    44a4:	ffe8869b          	addiw	a3,a7,-2
    44a8:	7c06bb0b          	th.extu	s6,a3,31,0
    44ac:	00730833          	add	a6,t1,t2
    44b0:	01680cb3          	add	s9,a6,s6
    44b4:	406c8fb3          	sub	t6,s9,t1
    44b8:	007ff293          	andi	t0,t6,7
    44bc:	8d1a                	mv	s10,t1
    44be:	08028663          	beqz	t0,454a <_vsnprintf+0x1c3a>
    44c2:	06728b63          	beq	t0,t2,4538 <_vsnprintf+0x1c28>
    44c6:	4509                	li	a0,2
    44c8:	06a28163          	beq	t0,a0,452a <_vsnprintf+0x1c1a>
    44cc:	4e8d                	li	t4,3
    44ce:	05d28763          	beq	t0,t4,451c <_vsnprintf+0x1c0c>
    44d2:	4e11                	li	t3,4
    44d4:	03c28d63          	beq	t0,t3,450e <_vsnprintf+0x1bfe>
    44d8:	4f15                	li	t5,5
    44da:	03e28363          	beq	t0,t5,4500 <_vsnprintf+0x1bf0>
    44de:	4599                	li	a1,6
    44e0:	00b28963          	beq	t0,a1,44f2 <_vsnprintf+0x1be2>
    44e4:	6602                	ld	a2,0(sp)
    44e6:	86a6                	mv	a3,s1
    44e8:	85ca                	mv	a1,s2
    44ea:	02000513          	li	a0,32
    44ee:	8d42                	mv	s10,a6
    44f0:	9402                	jalr	s0
    44f2:	866a                	mv	a2,s10
    44f4:	86a6                	mv	a3,s1
    44f6:	85ca                	mv	a1,s2
    44f8:	02000513          	li	a0,32
    44fc:	0d05                	addi	s10,s10,1
    44fe:	9402                	jalr	s0
    4500:	866a                	mv	a2,s10
    4502:	86a6                	mv	a3,s1
    4504:	85ca                	mv	a1,s2
    4506:	02000513          	li	a0,32
    450a:	0d05                	addi	s10,s10,1
    450c:	9402                	jalr	s0
    450e:	866a                	mv	a2,s10
    4510:	86a6                	mv	a3,s1
    4512:	85ca                	mv	a1,s2
    4514:	02000513          	li	a0,32
    4518:	0d05                	addi	s10,s10,1
    451a:	9402                	jalr	s0
    451c:	866a                	mv	a2,s10
    451e:	86a6                	mv	a3,s1
    4520:	85ca                	mv	a1,s2
    4522:	02000513          	li	a0,32
    4526:	0d05                	addi	s10,s10,1
    4528:	9402                	jalr	s0
    452a:	866a                	mv	a2,s10
    452c:	86a6                	mv	a3,s1
    452e:	85ca                	mv	a1,s2
    4530:	02000513          	li	a0,32
    4534:	0d05                	addi	s10,s10,1
    4536:	9402                	jalr	s0
    4538:	866a                	mv	a2,s10
    453a:	86a6                	mv	a3,s1
    453c:	0d05                	addi	s10,s10,1
    453e:	85ca                	mv	a1,s2
    4540:	02000513          	li	a0,32
    4544:	9402                	jalr	s0
    4546:	099d0363          	beq	s10,s9,45cc <_vsnprintf+0x1cbc>
    454a:	866a                	mv	a2,s10
    454c:	86a6                	mv	a3,s1
    454e:	85ca                	mv	a1,s2
    4550:	02000513          	li	a0,32
    4554:	9402                	jalr	s0
    4556:	001d0a93          	addi	s5,s10,1
    455a:	8656                	mv	a2,s5
    455c:	86a6                	mv	a3,s1
    455e:	85ca                	mv	a1,s2
    4560:	02000513          	li	a0,32
    4564:	9402                	jalr	s0
    4566:	002d0c13          	addi	s8,s10,2
    456a:	8662                	mv	a2,s8
    456c:	86a6                	mv	a3,s1
    456e:	85ca                	mv	a1,s2
    4570:	02000513          	li	a0,32
    4574:	9402                	jalr	s0
    4576:	003d0b93          	addi	s7,s10,3
    457a:	865e                	mv	a2,s7
    457c:	86a6                	mv	a3,s1
    457e:	85ca                	mv	a1,s2
    4580:	02000513          	li	a0,32
    4584:	9402                	jalr	s0
    4586:	004d0c13          	addi	s8,s10,4
    458a:	8662                	mv	a2,s8
    458c:	86a6                	mv	a3,s1
    458e:	85ca                	mv	a1,s2
    4590:	02000513          	li	a0,32
    4594:	9402                	jalr	s0
    4596:	005d0a93          	addi	s5,s10,5
    459a:	86a6                	mv	a3,s1
    459c:	8656                	mv	a2,s5
    459e:	85ca                	mv	a1,s2
    45a0:	02000513          	li	a0,32
    45a4:	9402                	jalr	s0
    45a6:	006d0b93          	addi	s7,s10,6
    45aa:	86a6                	mv	a3,s1
    45ac:	865e                	mv	a2,s7
    45ae:	85ca                	mv	a1,s2
    45b0:	02000513          	li	a0,32
    45b4:	9402                	jalr	s0
    45b6:	007d0c13          	addi	s8,s10,7
    45ba:	86a6                	mv	a3,s1
    45bc:	0d21                	addi	s10,s10,8
    45be:	8662                	mv	a2,s8
    45c0:	85ca                	mv	a1,s2
    45c2:	02000513          	li	a0,32
    45c6:	9402                	jalr	s0
    45c8:	f99d11e3          	bne	s10,s9,454a <_vsnprintf+0x1c3a>
    45cc:	6882                	ld	a7,0(sp)
    45ce:	988dc50b          	th.lbuia	a0,(s11),8,0
    45d2:	86a6                	mv	a3,s1
    45d4:	011b0733          	add	a4,s6,a7
    45d8:	00270793          	addi	a5,a4,2
    45dc:	85ca                	mv	a1,s2
    45de:	00170613          	addi	a2,a4,1
    45e2:	e03e                	sd	a5,0(sp)
    45e4:	9402                	jalr	s0
    45e6:	b109                	j	41e8 <_vsnprintf+0x18d8>
    45e8:	0025f793          	andi	a5,a1,2
    45ec:	68078b63          	beqz	a5,4c82 <_vsnprintf+0x2372>
    45f0:	000b83e3          	beqz	s7,4df6 <_vsnprintf+0x24e6>
    45f4:	000c9663          	bnez	s9,4600 <_vsnprintf+0x1cf0>
    45f8:	011c1463          	bne	s8,a7,4600 <_vsnprintf+0x1cf0>
    45fc:	6420406f          	j	8c3e <_vsnprintf+0x632e>
    4600:	4b89                	li	s7,2
    4602:	4ac1                	li	s5,16
    4604:	04f14503          	lbu	a0,79(sp)
    4608:	02000d13          	li	s10,32
    460c:	6682                	ld	a3,0(sp)
    460e:	01ab0c33          	add	s8,s6,s10
    4612:	03110c93          	addi	s9,sp,49
    4616:	419c07b3          	sub	a5,s8,s9
    461a:	9b36                	add	s6,s6,a3
    461c:	0077f893          	andi	a7,a5,7
    4620:	9b6a                	add	s6,s6,s10
    4622:	12088163          	beqz	a7,4744 <_vsnprintf+0x1e34>
    4626:	418b0633          	sub	a2,s6,s8
    462a:	86a6                	mv	a3,s1
    462c:	85ca                	mv	a1,s2
    462e:	ec46                	sd	a7,24(sp)
    4630:	9402                	jalr	s0
    4632:	6762                	ld	a4,24(sp)
    4634:	4605                	li	a2,1
    4636:	ffec4503          	lbu	a0,-2(s8)
    463a:	1c7d                	addi	s8,s8,-1
    463c:	10c70463          	beq	a4,a2,4744 <_vsnprintf+0x1e34>
    4640:	4389                	li	t2,2
    4642:	06770663          	beq	a4,t2,46ae <_vsnprintf+0x1d9e>
    4646:	430d                	li	t1,3
    4648:	04670b63          	beq	a4,t1,469e <_vsnprintf+0x1d8e>
    464c:	4811                	li	a6,4
    464e:	05070063          	beq	a4,a6,468e <_vsnprintf+0x1d7e>
    4652:	4f95                	li	t6,5
    4654:	03f70563          	beq	a4,t6,467e <_vsnprintf+0x1d6e>
    4658:	4299                	li	t0,6
    465a:	00570a63          	beq	a4,t0,466e <_vsnprintf+0x1d5e>
    465e:	418b0633          	sub	a2,s6,s8
    4662:	86a6                	mv	a3,s1
    4664:	85ca                	mv	a1,s2
    4666:	9402                	jalr	s0
    4668:	ffec4503          	lbu	a0,-2(s8)
    466c:	1c7d                	addi	s8,s8,-1
    466e:	418b0633          	sub	a2,s6,s8
    4672:	86a6                	mv	a3,s1
    4674:	85ca                	mv	a1,s2
    4676:	9402                	jalr	s0
    4678:	ffec4503          	lbu	a0,-2(s8)
    467c:	1c7d                	addi	s8,s8,-1
    467e:	418b0633          	sub	a2,s6,s8
    4682:	86a6                	mv	a3,s1
    4684:	85ca                	mv	a1,s2
    4686:	9402                	jalr	s0
    4688:	ffec4503          	lbu	a0,-2(s8)
    468c:	1c7d                	addi	s8,s8,-1
    468e:	418b0633          	sub	a2,s6,s8
    4692:	86a6                	mv	a3,s1
    4694:	85ca                	mv	a1,s2
    4696:	9402                	jalr	s0
    4698:	ffec4503          	lbu	a0,-2(s8)
    469c:	1c7d                	addi	s8,s8,-1
    469e:	418b0633          	sub	a2,s6,s8
    46a2:	86a6                	mv	a3,s1
    46a4:	85ca                	mv	a1,s2
    46a6:	9402                	jalr	s0
    46a8:	ffec4503          	lbu	a0,-2(s8)
    46ac:	1c7d                	addi	s8,s8,-1
    46ae:	418b0633          	sub	a2,s6,s8
    46b2:	86a6                	mv	a3,s1
    46b4:	85ca                	mv	a1,s2
    46b6:	9402                	jalr	s0
    46b8:	ffec4503          	lbu	a0,-2(s8)
    46bc:	1c7d                	addi	s8,s8,-1
    46be:	a059                	j	4744 <_vsnprintf+0x1e34>
    46c0:	ffec4503          	lbu	a0,-2(s8)
    46c4:	fffc0e13          	addi	t3,s8,-1
    46c8:	41cb0633          	sub	a2,s6,t3
    46cc:	86a6                	mv	a3,s1
    46ce:	85ca                	mv	a1,s2
    46d0:	9402                	jalr	s0
    46d2:	ffdc4503          	lbu	a0,-3(s8)
    46d6:	ffec0f13          	addi	t5,s8,-2
    46da:	41eb0633          	sub	a2,s6,t5
    46de:	86a6                	mv	a3,s1
    46e0:	85ca                	mv	a1,s2
    46e2:	9402                	jalr	s0
    46e4:	ffcc4503          	lbu	a0,-4(s8)
    46e8:	ffdc0593          	addi	a1,s8,-3
    46ec:	40bb0633          	sub	a2,s6,a1
    46f0:	86a6                	mv	a3,s1
    46f2:	85ca                	mv	a1,s2
    46f4:	9402                	jalr	s0
    46f6:	ffbc4503          	lbu	a0,-5(s8)
    46fa:	ffcc0793          	addi	a5,s8,-4
    46fe:	40fb0633          	sub	a2,s6,a5
    4702:	86a6                	mv	a3,s1
    4704:	85ca                	mv	a1,s2
    4706:	9402                	jalr	s0
    4708:	ffac4503          	lbu	a0,-6(s8)
    470c:	ffbc0893          	addi	a7,s8,-5
    4710:	411b0633          	sub	a2,s6,a7
    4714:	86a6                	mv	a3,s1
    4716:	85ca                	mv	a1,s2
    4718:	9402                	jalr	s0
    471a:	ff9c4503          	lbu	a0,-7(s8)
    471e:	ffac0613          	addi	a2,s8,-6
    4722:	86a6                	mv	a3,s1
    4724:	40cb0633          	sub	a2,s6,a2
    4728:	85ca                	mv	a1,s2
    472a:	9402                	jalr	s0
    472c:	ff8c4503          	lbu	a0,-8(s8)
    4730:	ff9c0713          	addi	a4,s8,-7
    4734:	86a6                	mv	a3,s1
    4736:	40eb0633          	sub	a2,s6,a4
    473a:	85ca                	mv	a1,s2
    473c:	9402                	jalr	s0
    473e:	ff7c4503          	lbu	a0,-9(s8)
    4742:	1c61                	addi	s8,s8,-8
    4744:	86a6                	mv	a3,s1
    4746:	418b0633          	sub	a2,s6,s8
    474a:	85ca                	mv	a1,s2
    474c:	9402                	jalr	s0
    474e:	f78c99e3          	bne	s9,s8,46c0 <_vsnprintf+0x1db0>
    4752:	6502                	ld	a0,0(sp)
    4754:	01a50eb3          	add	t4,a0,s10
    4758:	e076                	sd	t4,0(sp)
    475a:	a80b87e3          	beqz	s7,41e8 <_vsnprintf+0x18d8>
    475e:	7c0abb8b          	th.extu	s7,s5,31,0
    4762:	a95d73e3          	bgeu	s10,s5,41e8 <_vsnprintf+0x18d8>
    4766:	8af6                	mv	s5,t4
    4768:	8656                	mv	a2,s5
    476a:	86a6                	mv	a3,s1
    476c:	85ca                	mv	a1,s2
    476e:	02000513          	li	a0,32
    4772:	0d05                	addi	s10,s10,1
    4774:	0a85                	addi	s5,s5,1
    4776:	9402                	jalr	s0
    4778:	ff7d68e3          	bltu	s10,s7,4768 <_vsnprintf+0x1e58>
    477c:	e056                	sd	s5,0(sp)
    477e:	b4ad                	j	41e8 <_vsnprintf+0x18d8>
    4780:	660b8563          	beqz	s7,4dea <_vsnprintf+0x24da>
    4784:	000c8463          	beqz	s9,478c <_vsnprintf+0x1e7c>
    4788:	6c70106f          	j	664e <_vsnprintf+0x3d3e>
    478c:	7c0c338b          	th.extu	t2,s8,31,0
    4790:	007d1463          	bne	s10,t2,4798 <_vsnprintf+0x1e88>
    4794:	1140306f          	j	78a8 <_vsnprintf+0x4f98>
    4798:	47c1                	li	a5,16
    479a:	8abe                	mv	s5,a5
    479c:	4b89                	li	s7,2
    479e:	01a78463          	beq	a5,s10,47a6 <_vsnprintf+0x1e96>
    47a2:	6b10106f          	j	6652 <_vsnprintf+0x3d42>
    47a6:	1f40306f          	j	799a <_vsnprintf+0x508a>
    47aa:	0001                	nop
    47ac:	002b7613          	andi	a2,s6,2
    47b0:	5e061663          	bnez	a2,4d9c <_vsnprintf+0x248c>
    47b4:	00c57b93          	andi	s7,a0,12
    47b8:	7c0c3f8b          	th.extu	t6,s8,31,0
    47bc:	000b9463          	bnez	s7,47c4 <_vsnprintf+0x1eb4>
    47c0:	6000206f          	j	6dc0 <_vsnprintf+0x44b0>
    47c4:	000f9463          	bnez	t6,47cc <_vsnprintf+0x1ebc>
    47c8:	3740406f          	j	8b3c <_vsnprintf+0x622c>
    47cc:	47bd                	li	a5,15
    47ce:	4b81                	li	s7,0
    47d0:	4d01                	li	s10,0
    47d2:	40000c93          	li	s9,1024
    47d6:	8abe                	mv	s5,a5
    47d8:	03010b13          	addi	s6,sp,48
    47dc:	a1c9                	j	4c9e <_vsnprintf+0x238e>
    47de:	feeb7b13          	andi	s6,s6,-18
    47e2:	000b059b          	sext.w	a1,s6
    47e6:	2005f313          	andi	t1,a1,512
    47ea:	8aae                	mv	s5,a1
    47ec:	00030463          	beqz	t1,47f4 <_vsnprintf+0x1ee4>
    47f0:	3f80106f          	j	5be8 <_vsnprintf+0x32d8>
    47f4:	1005f813          	andi	a6,a1,256
    47f8:	40000e93          	li	t4,1024
    47fc:	60081563          	bnez	a6,4e06 <_vsnprintf+0x24f6>
    4800:	0405fe13          	andi	t3,a1,64
    4804:	580e1863          	bnez	t3,4d94 <_vsnprintf+0x2484>
    4808:	0805f293          	andi	t0,a1,128
    480c:	00029463          	bnez	t0,4814 <_vsnprintf+0x1f04>
    4810:	5ca0206f          	j	6dda <_vsnprintf+0x44ca>
    4814:	388dce0b          	th.lhia	t3,(s11),8,0
    4818:	40fe571b          	sraiw	a4,t3,0xf
    481c:	00ee4fb3          	xor	t6,t3,a4
    4820:	40ef8cbb          	subw	s9,t6,a4
    4824:	3c0cb38b          	th.extu	t2,s9,15,0
    4828:	000e1763          	bnez	t3,4836 <_vsnprintf+0x1f26>
    482c:	000e8463          	beqz	t4,4834 <_vsnprintf+0x1f24>
    4830:	5e00206f          	j	6e10 <_vsnprintf+0x4500>
    4834:	4381                	li	t2,0
    4836:	47a9                	li	a5,10
    4838:	02f3fb33          	remu	s6,t2,a5
    483c:	03010b93          	addi	s7,sp,48
    4840:	4aa5                	li	s5,9
    4842:	875e                	mv	a4,s7
    4844:	030b031b          	addiw	t1,s6,48
    4848:	02610823          	sb	t1,48(sp)
    484c:	02f3dfb3          	divu	t6,t2,a5
    4850:	107afc63          	bgeu	s5,t2,4968 <_vsnprintf+0x2058>
    4854:	03110713          	addi	a4,sp,49
    4858:	02fff633          	remu	a2,t6,a5
    485c:	0306081b          	addiw	a6,a2,48
    4860:	01070023          	sb	a6,0(a4)
    4864:	02ffdeb3          	divu	t4,t6,a5
    4868:	11faf063          	bgeu	s5,t6,4968 <_vsnprintf+0x2058>
    486c:	00000013          	nop
    4870:	00170293          	addi	t0,a4,1
    4874:	0888                	addi	a0,sp,80
    4876:	0e550963          	beq	a0,t0,4968 <_vsnprintf+0x2058>
    487a:	8716                	mv	a4,t0
    487c:	02fef633          	remu	a2,t4,a5
    4880:	03060f9b          	addiw	t6,a2,48
    4884:	01f28023          	sb	t6,0(t0)
    4888:	02fedcb3          	divu	s9,t4,a5
    488c:	0ddafe63          	bgeu	s5,t4,4968 <_vsnprintf+0x2058>
    4890:	02fcfd33          	remu	s10,s9,a5
    4894:	030d0f1b          	addiw	t5,s10,48
    4898:	08175f0b          	th.sbib	t5,(a4),1,0
    489c:	02fcd6b3          	divu	a3,s9,a5
    48a0:	0d9af463          	bgeu	s5,s9,4968 <_vsnprintf+0x2058>
    48a4:	00228713          	addi	a4,t0,2
    48a8:	02f6f3b3          	remu	t2,a3,a5
    48ac:	03038b1b          	addiw	s6,t2,48
    48b0:	01628123          	sb	s6,2(t0)
    48b4:	02f6d333          	divu	t1,a3,a5
    48b8:	0adaf863          	bgeu	s5,a3,4968 <_vsnprintf+0x2058>
    48bc:	00328713          	addi	a4,t0,3
    48c0:	02f37833          	remu	a6,t1,a5
    48c4:	03080e9b          	addiw	t4,a6,48
    48c8:	01d281a3          	sb	t4,3(t0)
    48cc:	02f35533          	divu	a0,t1,a5
    48d0:	086afc63          	bgeu	s5,t1,4968 <_vsnprintf+0x2058>
    48d4:	00428713          	addi	a4,t0,4
    48d8:	02f57633          	remu	a2,a0,a5
    48dc:	03060f9b          	addiw	t6,a2,48
    48e0:	01f28223          	sb	t6,4(t0)
    48e4:	02f55cb3          	divu	s9,a0,a5
    48e8:	08aaf063          	bgeu	s5,a0,4968 <_vsnprintf+0x2058>
    48ec:	00528713          	addi	a4,t0,5
    48f0:	02fcfd33          	remu	s10,s9,a5
    48f4:	030d0f1b          	addiw	t5,s10,48
    48f8:	01e282a3          	sb	t5,5(t0)
    48fc:	02fcd6b3          	divu	a3,s9,a5
    4900:	079af463          	bgeu	s5,s9,4968 <_vsnprintf+0x2058>
    4904:	00628713          	addi	a4,t0,6
    4908:	02f6f3b3          	remu	t2,a3,a5
    490c:	03038b1b          	addiw	s6,t2,48
    4910:	01628323          	sb	s6,6(t0)
    4914:	02f6d833          	divu	a6,a3,a5
    4918:	04daf863          	bgeu	s5,a3,4968 <_vsnprintf+0x2058>
    491c:	00728713          	addi	a4,t0,7
    4920:	02f87333          	remu	t1,a6,a5
    4924:	03030e9b          	addiw	t4,t1,48
    4928:	01d283a3          	sb	t4,7(t0)
    492c:	02f85533          	divu	a0,a6,a5
    4930:	030afc63          	bgeu	s5,a6,4968 <_vsnprintf+0x2058>
    4934:	00828713          	addi	a4,t0,8
    4938:	02f57633          	remu	a2,a0,a5
    493c:	03060f9b          	addiw	t6,a2,48
    4940:	01f28423          	sb	t6,8(t0)
    4944:	02f55cb3          	divu	s9,a0,a5
    4948:	02aaf063          	bgeu	s5,a0,4968 <_vsnprintf+0x2058>
    494c:	00928713          	addi	a4,t0,9
    4950:	8fe6                	mv	t6,s9
    4952:	02fcf633          	remu	a2,s9,a5
    4956:	0306081b          	addiw	a6,a2,48
    495a:	01070023          	sb	a6,0(a4)
    495e:	02ffdeb3          	divu	t4,t6,a5
    4962:	f1fae7e3          	bltu	s5,t6,4870 <_vsnprintf+0x1f60>
    4966:	0001                	nop
    4968:	41770733          	sub	a4,a4,s7
    496c:	0025fb13          	andi	s6,a1,2
    4970:	00170793          	addi	a5,a4,1
    4974:	8aae                	mv	s5,a1
    4976:	000b1463          	bnez	s6,497e <_vsnprintf+0x206e>
    497a:	1070106f          	j	6280 <_vsnprintf+0x3970>
    497e:	02000c13          	li	s8,32
    4982:	4b09                	li	s6,2
    4984:	01878463          	beq	a5,s8,498c <_vsnprintf+0x207c>
    4988:	2db0206f          	j	7462 <_vsnprintf+0x4b52>
    498c:	04f14503          	lbu	a0,79(sp)
    4990:	6302                	ld	t1,0(sp)
    4992:	02000c13          	li	s8,32
    4996:	018b8d33          	add	s10,s7,s8
    499a:	fffbcf13          	not	t5,s7
    499e:	006c0cb3          	add	s9,s8,t1
    49a2:	01af0333          	add	t1,t5,s10
    49a6:	00737813          	andi	a6,t1,7
    49aa:	019b8c33          	add	s8,s7,s9
    49ae:	00081463          	bnez	a6,49b6 <_vsnprintf+0x20a6>
    49b2:	6860206f          	j	7038 <_vsnprintf+0x4728>
    49b6:	41ac0633          	sub	a2,s8,s10
    49ba:	ec46                	sd	a7,24(sp)
    49bc:	f042                	sd	a6,32(sp)
    49be:	86a6                	mv	a3,s1
    49c0:	85ca                	mv	a1,s2
    49c2:	9402                	jalr	s0
    49c4:	68e2                	ld	a7,24(sp)
    49c6:	7a82                	ld	s5,32(sp)
    49c8:	4e85                	li	t4,1
    49ca:	1d7d                	addi	s10,s10,-1
    49cc:	fffd4503          	lbu	a0,-1(s10)
    49d0:	01da9463          	bne	s5,t4,49d8 <_vsnprintf+0x20c8>
    49d4:	6640206f          	j	7038 <_vsnprintf+0x4728>
    49d8:	4e09                	li	t3,2
    49da:	07ca8f63          	beq	s5,t3,4a58 <_vsnprintf+0x2148>
    49de:	460d                	li	a2,3
    49e0:	06ca8263          	beq	s5,a2,4a44 <_vsnprintf+0x2134>
    49e4:	4f91                	li	t6,4
    49e6:	05fa8563          	beq	s5,t6,4a30 <_vsnprintf+0x2120>
    49ea:	4715                	li	a4,5
    49ec:	02ea8863          	beq	s5,a4,4a1c <_vsnprintf+0x210c>
    49f0:	4699                	li	a3,6
    49f2:	00da8b63          	beq	s5,a3,4a08 <_vsnprintf+0x20f8>
    49f6:	41ac0633          	sub	a2,s8,s10
    49fa:	86a6                	mv	a3,s1
    49fc:	85ca                	mv	a1,s2
    49fe:	9402                	jalr	s0
    4a00:	68e2                	ld	a7,24(sp)
    4a02:	ffed4503          	lbu	a0,-2(s10)
    4a06:	1d7d                	addi	s10,s10,-1
    4a08:	41ac0633          	sub	a2,s8,s10
    4a0c:	ec46                	sd	a7,24(sp)
    4a0e:	86a6                	mv	a3,s1
    4a10:	85ca                	mv	a1,s2
    4a12:	9402                	jalr	s0
    4a14:	68e2                	ld	a7,24(sp)
    4a16:	ffed4503          	lbu	a0,-2(s10)
    4a1a:	1d7d                	addi	s10,s10,-1
    4a1c:	41ac0633          	sub	a2,s8,s10
    4a20:	ec46                	sd	a7,24(sp)
    4a22:	86a6                	mv	a3,s1
    4a24:	85ca                	mv	a1,s2
    4a26:	9402                	jalr	s0
    4a28:	68e2                	ld	a7,24(sp)
    4a2a:	ffed4503          	lbu	a0,-2(s10)
    4a2e:	1d7d                	addi	s10,s10,-1
    4a30:	41ac0633          	sub	a2,s8,s10
    4a34:	ec46                	sd	a7,24(sp)
    4a36:	86a6                	mv	a3,s1
    4a38:	85ca                	mv	a1,s2
    4a3a:	9402                	jalr	s0
    4a3c:	68e2                	ld	a7,24(sp)
    4a3e:	ffed4503          	lbu	a0,-2(s10)
    4a42:	1d7d                	addi	s10,s10,-1
    4a44:	41ac0633          	sub	a2,s8,s10
    4a48:	ec46                	sd	a7,24(sp)
    4a4a:	86a6                	mv	a3,s1
    4a4c:	85ca                	mv	a1,s2
    4a4e:	9402                	jalr	s0
    4a50:	68e2                	ld	a7,24(sp)
    4a52:	ffed4503          	lbu	a0,-2(s10)
    4a56:	1d7d                	addi	s10,s10,-1
    4a58:	41ac0633          	sub	a2,s8,s10
    4a5c:	86a6                	mv	a3,s1
    4a5e:	85ca                	mv	a1,s2
    4a60:	ec46                	sd	a7,24(sp)
    4a62:	9402                	jalr	s0
    4a64:	1d7d                	addi	s10,s10,-1
    4a66:	f05a                	sd	s6,32(sp)
    4a68:	fffd4503          	lbu	a0,-1(s10)
    4a6c:	a895                	j	4ae0 <_vsnprintf+0x21d0>
    4a6e:	8b6a                	mv	s6,s10
    4a70:	89eb450b          	th.lbuib	a0,(s6),-2,0
    4a74:	411c0633          	sub	a2,s8,a7
    4a78:	86a6                	mv	a3,s1
    4a7a:	85ca                	mv	a1,s2
    4a7c:	9402                	jalr	s0
    4a7e:	8aea                	mv	s5,s10
    4a80:	89dac50b          	th.lbuib	a0,(s5),-3,0
    4a84:	416c0633          	sub	a2,s8,s6
    4a88:	86a6                	mv	a3,s1
    4a8a:	85ca                	mv	a1,s2
    4a8c:	9402                	jalr	s0
    4a8e:	8b6a                	mv	s6,s10
    4a90:	89cb450b          	th.lbuib	a0,(s6),-4,0
    4a94:	415c0633          	sub	a2,s8,s5
    4a98:	86a6                	mv	a3,s1
    4a9a:	85ca                	mv	a1,s2
    4a9c:	9402                	jalr	s0
    4a9e:	8aea                	mv	s5,s10
    4aa0:	89bac50b          	th.lbuib	a0,(s5),-5,0
    4aa4:	416c0633          	sub	a2,s8,s6
    4aa8:	86a6                	mv	a3,s1
    4aaa:	85ca                	mv	a1,s2
    4aac:	9402                	jalr	s0
    4aae:	8b6a                	mv	s6,s10
    4ab0:	89ab450b          	th.lbuib	a0,(s6),-6,0
    4ab4:	415c0633          	sub	a2,s8,s5
    4ab8:	86a6                	mv	a3,s1
    4aba:	85ca                	mv	a1,s2
    4abc:	9402                	jalr	s0
    4abe:	8aea                	mv	s5,s10
    4ac0:	899ac50b          	th.lbuib	a0,(s5),-7,0
    4ac4:	86a6                	mv	a3,s1
    4ac6:	416c0633          	sub	a2,s8,s6
    4aca:	85ca                	mv	a1,s2
    4acc:	9402                	jalr	s0
    4ace:	898d450b          	th.lbuib	a0,(s10),-8,0
    4ad2:	86a6                	mv	a3,s1
    4ad4:	415c0633          	sub	a2,s8,s5
    4ad8:	85ca                	mv	a1,s2
    4ada:	9402                	jalr	s0
    4adc:	fffd4503          	lbu	a0,-1(s10)
    4ae0:	86a6                	mv	a3,s1
    4ae2:	41ac0633          	sub	a2,s8,s10
    4ae6:	85ca                	mv	a1,s2
    4ae8:	9402                	jalr	s0
    4aea:	fffd0893          	addi	a7,s10,-1
    4aee:	f91b90e3          	bne	s7,a7,4a6e <_vsnprintf+0x215e>
    4af2:	68e2                	ld	a7,24(sp)
    4af4:	7b02                	ld	s6,32(sp)
    4af6:	8ae6                	mv	s5,s9
    4af8:	380b0ee3          	beqz	s6,5694 <_vsnprintf+0x2d84>
    4afc:	6b82                	ld	s7,0(sp)
    4afe:	7c08bc0b          	th.extu	s8,a7,31,0
    4b02:	417a8d33          	sub	s10,s5,s7
    4b06:	398d77e3          	bgeu	s10,s8,5694 <_vsnprintf+0x2d84>
    4b0a:	fffd4513          	not	a0,s10
    4b0e:	018507b3          	add	a5,a0,s8
    4b12:	86a6                	mv	a3,s1
    4b14:	8656                	mv	a2,s5
    4b16:	85ca                	mv	a1,s2
    4b18:	02000513          	li	a0,32
    4b1c:	e056                	sd	s5,0(sp)
    4b1e:	0077fb93          	andi	s7,a5,7
    4b22:	001d0c93          	addi	s9,s10,1
    4b26:	9402                	jalr	s0
    4b28:	6282                	ld	t0,0(sp)
    4b2a:	001a8b13          	addi	s6,s5,1
    4b2e:	eb8cf963          	bgeu	s9,s8,41e0 <_vsnprintf+0x18d0>
    4b32:	0a0b8063          	beqz	s7,4bd2 <_vsnprintf+0x22c2>
    4b36:	4585                	li	a1,1
    4b38:	08bb8363          	beq	s7,a1,4bbe <_vsnprintf+0x22ae>
    4b3c:	4389                	li	t2,2
    4b3e:	067b8863          	beq	s7,t2,4bae <_vsnprintf+0x229e>
    4b42:	4f0d                	li	t5,3
    4b44:	05eb8d63          	beq	s7,t5,4b9e <_vsnprintf+0x228e>
    4b48:	4311                	li	t1,4
    4b4a:	046b8263          	beq	s7,t1,4b8e <_vsnprintf+0x227e>
    4b4e:	4815                	li	a6,5
    4b50:	030b8763          	beq	s7,a6,4b7e <_vsnprintf+0x226e>
    4b54:	4e99                	li	t4,6
    4b56:	01db8c63          	beq	s7,t4,4b6e <_vsnprintf+0x225e>
    4b5a:	865a                	mv	a2,s6
    4b5c:	86a6                	mv	a3,s1
    4b5e:	85ca                	mv	a1,s2
    4b60:	02000513          	li	a0,32
    4b64:	00228b13          	addi	s6,t0,2
    4b68:	002d0c93          	addi	s9,s10,2
    4b6c:	9402                	jalr	s0
    4b6e:	865a                	mv	a2,s6
    4b70:	86a6                	mv	a3,s1
    4b72:	85ca                	mv	a1,s2
    4b74:	02000513          	li	a0,32
    4b78:	0b05                	addi	s6,s6,1
    4b7a:	9402                	jalr	s0
    4b7c:	0c85                	addi	s9,s9,1
    4b7e:	865a                	mv	a2,s6
    4b80:	86a6                	mv	a3,s1
    4b82:	85ca                	mv	a1,s2
    4b84:	02000513          	li	a0,32
    4b88:	0b05                	addi	s6,s6,1
    4b8a:	9402                	jalr	s0
    4b8c:	0c85                	addi	s9,s9,1
    4b8e:	865a                	mv	a2,s6
    4b90:	86a6                	mv	a3,s1
    4b92:	85ca                	mv	a1,s2
    4b94:	02000513          	li	a0,32
    4b98:	0b05                	addi	s6,s6,1
    4b9a:	9402                	jalr	s0
    4b9c:	0c85                	addi	s9,s9,1
    4b9e:	865a                	mv	a2,s6
    4ba0:	86a6                	mv	a3,s1
    4ba2:	85ca                	mv	a1,s2
    4ba4:	02000513          	li	a0,32
    4ba8:	0b05                	addi	s6,s6,1
    4baa:	9402                	jalr	s0
    4bac:	0c85                	addi	s9,s9,1
    4bae:	865a                	mv	a2,s6
    4bb0:	86a6                	mv	a3,s1
    4bb2:	85ca                	mv	a1,s2
    4bb4:	02000513          	li	a0,32
    4bb8:	0b05                	addi	s6,s6,1
    4bba:	9402                	jalr	s0
    4bbc:	0c85                	addi	s9,s9,1
    4bbe:	865a                	mv	a2,s6
    4bc0:	86a6                	mv	a3,s1
    4bc2:	85ca                	mv	a1,s2
    4bc4:	02000513          	li	a0,32
    4bc8:	0c85                	addi	s9,s9,1
    4bca:	0b05                	addi	s6,s6,1
    4bcc:	9402                	jalr	s0
    4bce:	e18cf963          	bgeu	s9,s8,41e0 <_vsnprintf+0x18d0>
    4bd2:	865a                	mv	a2,s6
    4bd4:	86a6                	mv	a3,s1
    4bd6:	85ca                	mv	a1,s2
    4bd8:	02000513          	li	a0,32
    4bdc:	9402                	jalr	s0
    4bde:	001b0a93          	addi	s5,s6,1
    4be2:	8656                	mv	a2,s5
    4be4:	86a6                	mv	a3,s1
    4be6:	85ca                	mv	a1,s2
    4be8:	02000513          	li	a0,32
    4bec:	9402                	jalr	s0
    4bee:	002b0d13          	addi	s10,s6,2
    4bf2:	866a                	mv	a2,s10
    4bf4:	86a6                	mv	a3,s1
    4bf6:	85ca                	mv	a1,s2
    4bf8:	02000513          	li	a0,32
    4bfc:	9402                	jalr	s0
    4bfe:	003b0a93          	addi	s5,s6,3
    4c02:	8656                	mv	a2,s5
    4c04:	86a6                	mv	a3,s1
    4c06:	85ca                	mv	a1,s2
    4c08:	02000513          	li	a0,32
    4c0c:	9402                	jalr	s0
    4c0e:	004b0b93          	addi	s7,s6,4
    4c12:	865e                	mv	a2,s7
    4c14:	86a6                	mv	a3,s1
    4c16:	85ca                	mv	a1,s2
    4c18:	02000513          	li	a0,32
    4c1c:	9402                	jalr	s0
    4c1e:	005b0d13          	addi	s10,s6,5
    4c22:	86a6                	mv	a3,s1
    4c24:	866a                	mv	a2,s10
    4c26:	85ca                	mv	a1,s2
    4c28:	02000513          	li	a0,32
    4c2c:	9402                	jalr	s0
    4c2e:	006b0b93          	addi	s7,s6,6
    4c32:	86a6                	mv	a3,s1
    4c34:	865e                	mv	a2,s7
    4c36:	85ca                	mv	a1,s2
    4c38:	02000513          	li	a0,32
    4c3c:	9402                	jalr	s0
    4c3e:	007b0a93          	addi	s5,s6,7
    4c42:	86a6                	mv	a3,s1
    4c44:	8656                	mv	a2,s5
    4c46:	85ca                	mv	a1,s2
    4c48:	02000513          	li	a0,32
    4c4c:	0ca1                	addi	s9,s9,8
    4c4e:	0b21                	addi	s6,s6,8
    4c50:	9402                	jalr	s0
    4c52:	f98ce0e3          	bltu	s9,s8,4bd2 <_vsnprintf+0x22c2>
    4c56:	d8aff06f          	j	41e0 <_vsnprintf+0x18d0>
    4c5a:	0001                	nop
    4c5c:	4f1e6863          	bltu	t3,a7,514c <_vsnprintf+0x283c>
    4c60:	002b7f93          	andi	t6,s6,2
    4c64:	4a89                	li	s5,2
    4c66:	4e0f8a63          	beqz	t6,515a <_vsnprintf+0x284a>
    4c6a:	000d9463          	bnez	s11,4c72 <_vsnprintf+0x2362>
    4c6e:	fb8fe06f          	j	3426 <_vsnprintf+0xb16>
    4c72:	f2068253          	fmv.d.x	ft4,a3
    4c76:	1a1272d3          	fdiv.d	ft5,ft4,ft1
    4c7a:	e20286d3          	fmv.x.d	a3,ft5
    4c7e:	fa8fe06f          	j	3426 <_vsnprintf+0xb16>
    4c82:	00c5f393          	andi	t2,a1,12
    4c86:	7c0c3f8b          	th.extu	t6,s8,31,0
    4c8a:	00039463          	bnez	t2,4c92 <_vsnprintf+0x2382>
    4c8e:	0fa0206f          	j	6d88 <_vsnprintf+0x4478>
    4c92:	47bd                	li	a5,15
    4c94:	8abe                	mv	s5,a5
    4c96:	01f8e463          	bltu	a7,t6,4c9e <_vsnprintf+0x238e>
    4c9a:	0fa0206f          	j	6d94 <_vsnprintf+0x4484>
    4c9e:	02000e93          	li	t4,32
    4ca2:	41ae8f33          	sub	t5,t4,s10
    4ca6:	007f7893          	andi	a7,t5,7
    4caa:	01ab0733          	add	a4,s6,s10
    4cae:	03000313          	li	t1,48
    4cb2:	06088763          	beqz	a7,4d20 <_vsnprintf+0x2410>
    4cb6:	0d05                	addi	s10,s10,1
    4cb8:	1817530b          	th.sbia	t1,(a4),1,0
    4cbc:	d7fd0163          	beq	s10,t6,421e <_vsnprintf+0x190e>
    4cc0:	4505                	li	a0,1
    4cc2:	04a88f63          	beq	a7,a0,4d20 <_vsnprintf+0x2410>
    4cc6:	4c09                	li	s8,2
    4cc8:	05888763          	beq	a7,s8,4d16 <_vsnprintf+0x2406>
    4ccc:	460d                	li	a2,3
    4cce:	02c88f63          	beq	a7,a2,4d0c <_vsnprintf+0x23fc>
    4cd2:	4391                	li	t2,4
    4cd4:	02788763          	beq	a7,t2,4d02 <_vsnprintf+0x23f2>
    4cd8:	4815                	li	a6,5
    4cda:	01088f63          	beq	a7,a6,4cf8 <_vsnprintf+0x23e8>
    4cde:	4299                	li	t0,6
    4ce0:	00588763          	beq	a7,t0,4cee <_vsnprintf+0x23de>
    4ce4:	0d05                	addi	s10,s10,1
    4ce6:	1817530b          	th.sbia	t1,(a4),1,0
    4cea:	d3fd0a63          	beq	s10,t6,421e <_vsnprintf+0x190e>
    4cee:	0d05                	addi	s10,s10,1
    4cf0:	1817530b          	th.sbia	t1,(a4),1,0
    4cf4:	d3fd0563          	beq	s10,t6,421e <_vsnprintf+0x190e>
    4cf8:	0d05                	addi	s10,s10,1
    4cfa:	1817530b          	th.sbia	t1,(a4),1,0
    4cfe:	d3fd0063          	beq	s10,t6,421e <_vsnprintf+0x190e>
    4d02:	0d05                	addi	s10,s10,1
    4d04:	1817530b          	th.sbia	t1,(a4),1,0
    4d08:	d1fd0b63          	beq	s10,t6,421e <_vsnprintf+0x190e>
    4d0c:	0d05                	addi	s10,s10,1
    4d0e:	1817530b          	th.sbia	t1,(a4),1,0
    4d12:	d1fd0663          	beq	s10,t6,421e <_vsnprintf+0x190e>
    4d16:	0d05                	addi	s10,s10,1
    4d18:	1817530b          	th.sbia	t1,(a4),1,0
    4d1c:	d1fd0163          	beq	s10,t6,421e <_vsnprintf+0x190e>
    4d20:	01dd1463          	bne	s10,t4,4d28 <_vsnprintf+0x2418>
    4d24:	4520306f          	j	8176 <_vsnprintf+0x5866>
    4d28:	0d05                	addi	s10,s10,1
    4d2a:	00670023          	sb	t1,0(a4)
    4d2e:	86ea                	mv	a3,s10
    4d30:	cffd0763          	beq	s10,t6,421e <_vsnprintf+0x190e>
    4d34:	0d05                	addi	s10,s10,1
    4d36:	006700a3          	sb	t1,1(a4)
    4d3a:	cffd0263          	beq	s10,t6,421e <_vsnprintf+0x190e>
    4d3e:	00268d13          	addi	s10,a3,2
    4d42:	00670123          	sb	t1,2(a4)
    4d46:	cdfd0c63          	beq	s10,t6,421e <_vsnprintf+0x190e>
    4d4a:	00368d13          	addi	s10,a3,3
    4d4e:	006701a3          	sb	t1,3(a4)
    4d52:	cdfd0663          	beq	s10,t6,421e <_vsnprintf+0x190e>
    4d56:	00468d13          	addi	s10,a3,4
    4d5a:	00670223          	sb	t1,4(a4)
    4d5e:	cdfd0063          	beq	s10,t6,421e <_vsnprintf+0x190e>
    4d62:	00568d13          	addi	s10,a3,5
    4d66:	006702a3          	sb	t1,5(a4)
    4d6a:	cbfd0a63          	beq	s10,t6,421e <_vsnprintf+0x190e>
    4d6e:	00668d13          	addi	s10,a3,6
    4d72:	00670323          	sb	t1,6(a4)
    4d76:	cbfd0463          	beq	s10,t6,421e <_vsnprintf+0x190e>
    4d7a:	006703a3          	sb	t1,7(a4)
    4d7e:	00768d13          	addi	s10,a3,7
    4d82:	0721                	addi	a4,a4,8
    4d84:	f9fd1ee3          	bne	s10,t6,4d20 <_vsnprintf+0x2410>
    4d88:	c96ff06f          	j	421e <_vsnprintf+0x190e>
    4d8c:	47c1                	li	a5,16
    4d8e:	86be                	mv	a3,a5
    4d90:	db9fe06f          	j	3b48 <_vsnprintf+0x1238>
    4d94:	988dce0b          	th.lbuia	t3,(s11),8,0
    4d98:	83f2                	mv	t2,t3
    4d9a:	b479                	j	4828 <_vsnprintf+0x1f18>
    4d9c:	00457813          	andi	a6,a0,4
    4da0:	00081463          	bnez	a6,4da8 <_vsnprintf+0x2498>
    4da4:	04a0206f          	j	6dee <_vsnprintf+0x44de>
    4da8:	4b89                	li	s7,2
    4daa:	4ac1                	li	s5,16
    4dac:	03010b13          	addi	s6,sp,48
    4db0:	00278c33          	add	s8,a5,sp
    4db4:	02b00513          	li	a0,43
    4db8:	00178d13          	addi	s10,a5,1
    4dbc:	02ac0823          	sb	a0,48(s8)
    4dc0:	b0b1                	j	460c <_vsnprintf+0x1cfc>
    4dc2:	47bd                	li	a5,15
    4dc4:	8abe                	mv	s5,a5
    4dc6:	c50ff06f          	j	4216 <_vsnprintf+0x1906>
    4dca:	8817c70b          	th.lbuib	a4,(a5),1,0
    4dce:	c319                	beqz	a4,4dd4 <_vsnprintf+0x24c4>
    4dd0:	856fe06f          	j	2e26 <_vsnprintf+0x516>
    4dd4:	8d6fe06f          	j	2eaa <_vsnprintf+0x59a>
    4dd8:	080ff513          	andi	a0,t6,128
    4ddc:	e119                	bnez	a0,4de2 <_vsnprintf+0x24d2>
    4dde:	4920206f          	j	7270 <_vsnprintf+0x4960>
    4de2:	b88dce8b          	th.lhuia	t4,(s11),8,0
    4de6:	da5fe06f          	j	3b8a <_vsnprintf+0x127a>
    4dea:	02000c13          	li	s8,32
    4dee:	018d0463          	beq	s10,s8,4df6 <_vsnprintf+0x24e6>
    4df2:	6290306f          	j	8c1a <_vsnprintf+0x630a>
    4df6:	04f14503          	lbu	a0,79(sp)
    4dfa:	4b89                	li	s7,2
    4dfc:	4ac1                	li	s5,16
    4dfe:	02000d13          	li	s10,32
    4e02:	80bff06f          	j	460c <_vsnprintf+0x1cfc>
    4e06:	886e                	mv	a6,s11
    4e08:	78884e0b          	th.ldia	t3,(a6),8,0
    4e0c:	000e0463          	beqz	t3,4e14 <_vsnprintf+0x2504>
    4e10:	f3ffe06f          	j	3d4e <_vsnprintf+0x143e>
    4e14:	002afd93          	andi	s11,s5,2
    4e18:	000d8463          	beqz	s11,4e20 <_vsnprintf+0x2510>
    4e1c:	6500306f          	j	846c <_vsnprintf+0x5b5c>
    4e20:	7c0c3d0b          	th.extu	s10,s8,31,0
    4e24:	4781                	li	a5,0
    4e26:	03010313          	addi	t1,sp,48
    4e2a:	00089463          	bnez	a7,4e32 <_vsnprintf+0x2522>
    4e2e:	6600306f          	j	848e <_vsnprintf+0x5b7e>
    4e32:	000d1463          	bnez	s10,4e3a <_vsnprintf+0x252a>
    4e36:	6790306f          	j	8cae <_vsnprintf+0x639e>
    4e3a:	02000513          	li	a0,32
    4e3e:	40f50f33          	sub	t5,a0,a5
    4e42:	007f7a93          	andi	s5,t5,7
    4e46:	00f30733          	add	a4,t1,a5
    4e4a:	03000e93          	li	t4,48
    4e4e:	060a8763          	beqz	s5,4ebc <_vsnprintf+0x25ac>
    4e52:	0785                	addi	a5,a5,1
    4e54:	18175e8b          	th.sbia	t4,(a4),1,0
    4e58:	0da7f663          	bgeu	a5,s10,4f24 <_vsnprintf+0x2614>
    4e5c:	4605                	li	a2,1
    4e5e:	04ca8f63          	beq	s5,a2,4ebc <_vsnprintf+0x25ac>
    4e62:	4289                	li	t0,2
    4e64:	045a8763          	beq	s5,t0,4eb2 <_vsnprintf+0x25a2>
    4e68:	4c8d                	li	s9,3
    4e6a:	039a8f63          	beq	s5,s9,4ea8 <_vsnprintf+0x2598>
    4e6e:	4c11                	li	s8,4
    4e70:	038a8763          	beq	s5,s8,4e9e <_vsnprintf+0x258e>
    4e74:	4b95                	li	s7,5
    4e76:	017a8f63          	beq	s5,s7,4e94 <_vsnprintf+0x2584>
    4e7a:	4f99                	li	t6,6
    4e7c:	01fa8763          	beq	s5,t6,4e8a <_vsnprintf+0x257a>
    4e80:	0785                	addi	a5,a5,1
    4e82:	18175e8b          	th.sbia	t4,(a4),1,0
    4e86:	09a7ff63          	bgeu	a5,s10,4f24 <_vsnprintf+0x2614>
    4e8a:	0785                	addi	a5,a5,1
    4e8c:	18175e8b          	th.sbia	t4,(a4),1,0
    4e90:	09a7fa63          	bgeu	a5,s10,4f24 <_vsnprintf+0x2614>
    4e94:	0785                	addi	a5,a5,1
    4e96:	18175e8b          	th.sbia	t4,(a4),1,0
    4e9a:	09a7f563          	bgeu	a5,s10,4f24 <_vsnprintf+0x2614>
    4e9e:	0785                	addi	a5,a5,1
    4ea0:	18175e8b          	th.sbia	t4,(a4),1,0
    4ea4:	09a7f063          	bgeu	a5,s10,4f24 <_vsnprintf+0x2614>
    4ea8:	0785                	addi	a5,a5,1
    4eaa:	18175e8b          	th.sbia	t4,(a4),1,0
    4eae:	07a7fb63          	bgeu	a5,s10,4f24 <_vsnprintf+0x2614>
    4eb2:	0785                	addi	a5,a5,1
    4eb4:	18175e8b          	th.sbia	t4,(a4),1,0
    4eb8:	07a7f663          	bgeu	a5,s10,4f24 <_vsnprintf+0x2614>
    4ebc:	00a79463          	bne	a5,a0,4ec4 <_vsnprintf+0x25b4>
    4ec0:	3130206f          	j	79d2 <_vsnprintf+0x50c2>
    4ec4:	0785                	addi	a5,a5,1
    4ec6:	01d70023          	sb	t4,0(a4)
    4eca:	83be                	mv	t2,a5
    4ecc:	05a7fc63          	bgeu	a5,s10,4f24 <_vsnprintf+0x2614>
    4ed0:	0785                	addi	a5,a5,1
    4ed2:	01d700a3          	sb	t4,1(a4)
    4ed6:	05a7f763          	bgeu	a5,s10,4f24 <_vsnprintf+0x2614>
    4eda:	00238793          	addi	a5,t2,2
    4ede:	01d70123          	sb	t4,2(a4)
    4ee2:	05a7f163          	bgeu	a5,s10,4f24 <_vsnprintf+0x2614>
    4ee6:	00338793          	addi	a5,t2,3
    4eea:	01d701a3          	sb	t4,3(a4)
    4eee:	03a7fb63          	bgeu	a5,s10,4f24 <_vsnprintf+0x2614>
    4ef2:	00438793          	addi	a5,t2,4
    4ef6:	01d70223          	sb	t4,4(a4)
    4efa:	03a7f563          	bgeu	a5,s10,4f24 <_vsnprintf+0x2614>
    4efe:	00538793          	addi	a5,t2,5
    4f02:	01d702a3          	sb	t4,5(a4)
    4f06:	01a7ff63          	bgeu	a5,s10,4f24 <_vsnprintf+0x2614>
    4f0a:	00638793          	addi	a5,t2,6
    4f0e:	01d70323          	sb	t4,6(a4)
    4f12:	01a7f963          	bgeu	a5,s10,4f24 <_vsnprintf+0x2614>
    4f16:	01d703a3          	sb	t4,7(a4)
    4f1a:	00738793          	addi	a5,t2,7
    4f1e:	0721                	addi	a4,a4,8
    4f20:	f9a7eee3          	bltu	a5,s10,4ebc <_vsnprintf+0x25ac>
    4f24:	000d9463          	bnez	s11,4f2c <_vsnprintf+0x261c>
    4f28:	6c60306f          	j	85ee <_vsnprintf+0x5cde>
    4f2c:	7c08b68b          	th.extu	a3,a7,31,0
    4f30:	00d7f463          	bgeu	a5,a3,4f38 <_vsnprintf+0x2628>
    4f34:	3b00206f          	j	72e4 <_vsnprintf+0x49d4>
    4f38:	86be                	mv	a3,a5
    4f3a:	00a79463          	bne	a5,a0,4f42 <_vsnprintf+0x2632>
    4f3e:	2a10206f          	j	79de <_vsnprintf+0x50ce>
    4f42:	000e4463          	bltz	t3,4f4a <_vsnprintf+0x263a>
    4f46:	5630306f          	j	8ca8 <_vsnprintf+0x6398>
    4f4a:	00268f33          	add	t5,a3,sp
    4f4e:	02d00613          	li	a2,45
    4f52:	02cf0823          	sb	a2,48(t5)
    4f56:	0035f793          	andi	a5,a1,3
    4f5a:	00168d13          	addi	s10,a3,1
    4f5e:	c399                	beqz	a5,4f64 <_vsnprintf+0x2654>
    4f60:	53b0306f          	j	8c9a <_vsnprintf+0x638a>
    4f64:	7c08bb8b          	th.extu	s7,a7,31,0
    4f68:	8dc2                	mv	s11,a6
    4f6a:	4b01                	li	s6,0
    4f6c:	017d6463          	bltu	s10,s7,4f74 <_vsnprintf+0x2664>
    4f70:	5210306f          	j	8c90 <_vsnprintf+0x6380>
    4f74:	6602                	ld	a2,0(sp)
    4f76:	85ca                	mv	a1,s2
    4f78:	ec46                	sd	a7,24(sp)
    4f7a:	40cd0cb3          	sub	s9,s10,a2
    4f7e:	fffcc313          	not	t1,s9
    4f82:	40c30e33          	sub	t3,t1,a2
    4f86:	86a6                	mv	a3,s1
    4f88:	02000513          	li	a0,32
    4f8c:	017e0ab3          	add	s5,t3,s7
    4f90:	00160c13          	addi	s8,a2,1
    4f94:	9402                	jalr	s0
    4f96:	018c85b3          	add	a1,s9,s8
    4f9a:	68e2                	ld	a7,24(sp)
    4f9c:	007afa93          	andi	s5,s5,7
    4fa0:	1575f563          	bgeu	a1,s7,50ea <_vsnprintf+0x27da>
    4fa4:	0a0a8863          	beqz	s5,5054 <_vsnprintf+0x2744>
    4fa8:	4685                	li	a3,1
    4faa:	08da8863          	beq	s5,a3,503a <_vsnprintf+0x272a>
    4fae:	4809                	li	a6,2
    4fb0:	070a8c63          	beq	s5,a6,5028 <_vsnprintf+0x2718>
    4fb4:	428d                	li	t0,3
    4fb6:	065a8063          	beq	s5,t0,5016 <_vsnprintf+0x2706>
    4fba:	4f91                	li	t6,4
    4fbc:	05fa8463          	beq	s5,t6,5004 <_vsnprintf+0x26f4>
    4fc0:	4395                	li	t2,5
    4fc2:	027a8863          	beq	s5,t2,4ff2 <_vsnprintf+0x26e2>
    4fc6:	4719                	li	a4,6
    4fc8:	00ea8c63          	beq	s5,a4,4fe0 <_vsnprintf+0x26d0>
    4fcc:	8662                	mv	a2,s8
    4fce:	ec46                	sd	a7,24(sp)
    4fd0:	86a6                	mv	a3,s1
    4fd2:	85ca                	mv	a1,s2
    4fd4:	02000513          	li	a0,32
    4fd8:	6c02                	ld	s8,0(sp)
    4fda:	9402                	jalr	s0
    4fdc:	68e2                	ld	a7,24(sp)
    4fde:	0c09                	addi	s8,s8,2
    4fe0:	8662                	mv	a2,s8
    4fe2:	ec46                	sd	a7,24(sp)
    4fe4:	86a6                	mv	a3,s1
    4fe6:	85ca                	mv	a1,s2
    4fe8:	02000513          	li	a0,32
    4fec:	9402                	jalr	s0
    4fee:	68e2                	ld	a7,24(sp)
    4ff0:	0c05                	addi	s8,s8,1
    4ff2:	8662                	mv	a2,s8
    4ff4:	ec46                	sd	a7,24(sp)
    4ff6:	86a6                	mv	a3,s1
    4ff8:	85ca                	mv	a1,s2
    4ffa:	02000513          	li	a0,32
    4ffe:	9402                	jalr	s0
    5000:	68e2                	ld	a7,24(sp)
    5002:	0c05                	addi	s8,s8,1
    5004:	8662                	mv	a2,s8
    5006:	ec46                	sd	a7,24(sp)
    5008:	86a6                	mv	a3,s1
    500a:	85ca                	mv	a1,s2
    500c:	02000513          	li	a0,32
    5010:	9402                	jalr	s0
    5012:	68e2                	ld	a7,24(sp)
    5014:	0c05                	addi	s8,s8,1
    5016:	8662                	mv	a2,s8
    5018:	ec46                	sd	a7,24(sp)
    501a:	86a6                	mv	a3,s1
    501c:	85ca                	mv	a1,s2
    501e:	02000513          	li	a0,32
    5022:	9402                	jalr	s0
    5024:	68e2                	ld	a7,24(sp)
    5026:	0c05                	addi	s8,s8,1
    5028:	8662                	mv	a2,s8
    502a:	ec46                	sd	a7,24(sp)
    502c:	86a6                	mv	a3,s1
    502e:	85ca                	mv	a1,s2
    5030:	02000513          	li	a0,32
    5034:	9402                	jalr	s0
    5036:	68e2                	ld	a7,24(sp)
    5038:	0c05                	addi	s8,s8,1
    503a:	8662                	mv	a2,s8
    503c:	02000513          	li	a0,32
    5040:	ec46                	sd	a7,24(sp)
    5042:	86a6                	mv	a3,s1
    5044:	85ca                	mv	a1,s2
    5046:	9402                	jalr	s0
    5048:	0c05                	addi	s8,s8,1
    504a:	018c8533          	add	a0,s9,s8
    504e:	68e2                	ld	a7,24(sp)
    5050:	09757d63          	bgeu	a0,s7,50ea <_vsnprintf+0x27da>
    5054:	ec5a                	sd	s6,24(sp)
    5056:	f06e                	sd	s11,32(sp)
    5058:	8dea                	mv	s11,s10
    505a:	8d46                	mv	s10,a7
    505c:	8662                	mv	a2,s8
    505e:	86a6                	mv	a3,s1
    5060:	85ca                	mv	a1,s2
    5062:	02000513          	li	a0,32
    5066:	9402                	jalr	s0
    5068:	001c0a93          	addi	s5,s8,1
    506c:	8656                	mv	a2,s5
    506e:	86a6                	mv	a3,s1
    5070:	85ca                	mv	a1,s2
    5072:	02000513          	li	a0,32
    5076:	9402                	jalr	s0
    5078:	002c0b13          	addi	s6,s8,2
    507c:	865a                	mv	a2,s6
    507e:	86a6                	mv	a3,s1
    5080:	85ca                	mv	a1,s2
    5082:	02000513          	li	a0,32
    5086:	9402                	jalr	s0
    5088:	003c0a93          	addi	s5,s8,3
    508c:	8656                	mv	a2,s5
    508e:	86a6                	mv	a3,s1
    5090:	85ca                	mv	a1,s2
    5092:	02000513          	li	a0,32
    5096:	9402                	jalr	s0
    5098:	004c0b13          	addi	s6,s8,4
    509c:	865a                	mv	a2,s6
    509e:	86a6                	mv	a3,s1
    50a0:	85ca                	mv	a1,s2
    50a2:	02000513          	li	a0,32
    50a6:	9402                	jalr	s0
    50a8:	005c0a93          	addi	s5,s8,5
    50ac:	8656                	mv	a2,s5
    50ae:	86a6                	mv	a3,s1
    50b0:	85ca                	mv	a1,s2
    50b2:	02000513          	li	a0,32
    50b6:	9402                	jalr	s0
    50b8:	006c0b13          	addi	s6,s8,6
    50bc:	86a6                	mv	a3,s1
    50be:	865a                	mv	a2,s6
    50c0:	85ca                	mv	a1,s2
    50c2:	02000513          	li	a0,32
    50c6:	9402                	jalr	s0
    50c8:	007c0a93          	addi	s5,s8,7
    50cc:	86a6                	mv	a3,s1
    50ce:	8656                	mv	a2,s5
    50d0:	85ca                	mv	a1,s2
    50d2:	02000513          	li	a0,32
    50d6:	0c21                	addi	s8,s8,8
    50d8:	9402                	jalr	s0
    50da:	018c88b3          	add	a7,s9,s8
    50de:	f778efe3          	bltu	a7,s7,505c <_vsnprintf+0x274c>
    50e2:	88ea                	mv	a7,s10
    50e4:	8d6e                	mv	s10,s11
    50e6:	6b62                	ld	s6,24(sp)
    50e8:	7d82                	ld	s11,32(sp)
    50ea:	6302                	ld	t1,0(sp)
    50ec:	fffb8e93          	addi	t4,s7,-1
    50f0:	001d0793          	addi	a5,s10,1
    50f4:	41ae8f33          	sub	t5,t4,s10
    50f8:	00fbb633          	sltu	a2,s7,a5
    50fc:	42c01f0b          	th.mvnez	t5,zero,a2
    5100:	00130e13          	addi	t3,t1,1
    5104:	01cf03b3          	add	t2,t5,t3
    5108:	8e1e                	mv	t3,t2
    510a:	000d1463          	bnez	s10,5112 <_vsnprintf+0x2802>
    510e:	f37fe06f          	j	4044 <_vsnprintf+0x1734>
    5112:	03010313          	addi	t1,sp,48
    5116:	006d06b3          	add	a3,s10,t1
    511a:	fff6c503          	lbu	a0,-1(a3)
    511e:	d97fe06f          	j	3eb4 <_vsnprintf+0x15a4>
    5122:	00678023          	sb	t1,0(a5)
    5126:	006780a3          	sb	t1,1(a5)
    512a:	00678123          	sb	t1,2(a5)
    512e:	006781a3          	sb	t1,3(a5)
    5132:	00678223          	sb	t1,4(a5)
    5136:	006782a3          	sb	t1,5(a5)
    513a:	00678323          	sb	t1,6(a5)
    513e:	006783a3          	sb	t1,7(a5)
    5142:	07a1                	addi	a5,a5,8
    5144:	fde79fe3          	bne	a5,t5,5122 <_vsnprintf+0x2812>
    5148:	cf4fe06f          	j	363c <_vsnprintf+0xd2c>
    514c:	002afe93          	andi	t4,s5,2
    5150:	4a89                	li	s5,2
    5152:	b00e9ce3          	bnez	t4,4c6a <_vsnprintf+0x235a>
    5156:	41c887bb          	subw	a5,a7,t3
    515a:	4a81                	li	s5,0
    515c:	b639                	j	4c6a <_vsnprintf+0x235a>
    515e:	e032                	sd	a2,0(sp)
    5160:	a14ff06f          	j	4374 <_vsnprintf+0x1a64>
    5164:	060b8263          	beqz	s7,51c8 <_vsnprintf+0x28b8>
    5168:	000c8463          	beqz	s9,5170 <_vsnprintf+0x2860>
    516c:	10c0206f          	j	7278 <_vsnprintf+0x4968>
    5170:	fff78893          	addi	a7,a5,-1
    5174:	8d3e                	mv	s10,a5
    5176:	01fd1463          	bne	s10,t6,517e <_vsnprintf+0x286e>
    517a:	4f20306f          	j	866c <_vsnprintf+0x5d5c>
    517e:	00fd1463          	bne	s10,a5,5186 <_vsnprintf+0x2876>
    5182:	0170206f          	j	7998 <_vsnprintf+0x5088>
    5186:	002d0633          	add	a2,s10,sp
    518a:	05800393          	li	t2,88
    518e:	001d0793          	addi	a5,s10,1
    5192:	02760823          	sb	t2,48(a2)
    5196:	4b81                	li	s7,0
    5198:	00178d13          	addi	s10,a5,1
    519c:	00278833          	add	a6,a5,sp
    51a0:	03000c93          	li	s9,48
    51a4:	03980823          	sb	s9,48(a6)
    51a8:	02000f93          	li	t6,32
    51ac:	c5fd0c63          	beq	s10,t6,4604 <_vsnprintf+0x1cf4>
    51b0:	0045f513          	andi	a0,a1,4
    51b4:	c119                	beqz	a0,51ba <_vsnprintf+0x28aa>
    51b6:	0090206f          	j	79be <_vsnprintf+0x50ae>
    51ba:	0085f313          	andi	t1,a1,8
    51be:	02030c63          	beqz	t1,51f6 <_vsnprintf+0x28e6>
    51c2:	87ea                	mv	a5,s10
    51c4:	a829                	j	51de <_vsnprintf+0x28ce>
    51c6:	0001                	nop
    51c8:	0045fb93          	andi	s7,a1,4
    51cc:	000b8463          	beqz	s7,51d4 <_vsnprintf+0x28c4>
    51d0:	27c0206f          	j	744c <_vsnprintf+0x4b3c>
    51d4:	0085fc93          	andi	s9,a1,8
    51d8:	000c8d63          	beqz	s9,51f2 <_vsnprintf+0x28e2>
    51dc:	4b81                	li	s7,0
    51de:	00278e33          	add	t3,a5,sp
    51e2:	02000513          	li	a0,32
    51e6:	00178d13          	addi	s10,a5,1
    51ea:	02ae0823          	sb	a0,48(t3)
    51ee:	c1eff06f          	j	460c <_vsnprintf+0x1cfc>
    51f2:	8d3e                	mv	s10,a5
    51f4:	4b81                	li	s7,0
    51f6:	020d0813          	addi	a6,s10,32
    51fa:	03010c93          	addi	s9,sp,48
    51fe:	01980fb3          	add	t6,a6,s9
    5202:	fdffc503          	lbu	a0,-33(t6)
    5206:	c06ff06f          	j	460c <_vsnprintf+0x1cfc>
    520a:	87c6                	mv	a5,a7
    520c:	8b6a                	mv	s6,s10
    520e:	4d81                	li	s11,0
    5210:	4e01                	li	t3,0
    5212:	f2068553          	fmv.d.x	fa0,a3
    5216:	22a515d3          	fneg.d	fa1,fa0
    521a:	e20586d3          	fmv.x.d	a3,fa1
    521e:	a18fe06f          	j	3436 <_vsnprintf+0xb26>
    5222:	8aee                	mv	s5,s11
    5224:	788acd8b          	th.ldia	s11,(s5),8,0
    5228:	010ffd13          	andi	s10,t6,16
    522c:	000d9963          	bnez	s11,523e <_vsnprintf+0x292e>
    5230:	fefffe13          	andi	t3,t6,-17
    5234:	000e061b          	sext.w	a2,t3
    5238:	040b92e3          	bnez	s7,5a7c <_vsnprintf+0x316c>
    523c:	4d01                	li	s10,0
    523e:	1456328b          	th.extu	t0,a2,5,5
    5242:	fff28f93          	addi	t6,t0,-1
    5246:	020fff13          	andi	t5,t6,32
    524a:	037f051b          	addiw	a0,t5,55
    524e:	02fddf33          	divu	t5,s11,a5
    5252:	876e                	mv	a4,s11
    5254:	43a5                	li	t2,9
    5256:	03010813          	addi	a6,sp,48
    525a:	85c2                	mv	a1,a6
    525c:	22ff170b          	th.muls	a4,t5,a5
    5260:	0ff77e93          	zext.b	t4,a4
    5264:	030e831b          	addiw	t1,t4,48
    5268:	01d50cbb          	addw	s9,a0,t4
    526c:	0ff37b13          	zext.b	s6,t1
    5270:	0ffcfe13          	zext.b	t3,s9
    5274:	00e3b2b3          	sltu	t0,t2,a4
    5278:	405b1e0b          	th.mveqz	t3,s6,t0
    527c:	03c10823          	sb	t3,48(sp)
    5280:	64fdeb63          	bltu	s11,a5,58d6 <_vsnprintf+0x2fc6>
    5284:	03110593          	addi	a1,sp,49
    5288:	02ff5db3          	divu	s11,t5,a5
    528c:	8efa                	mv	t4,t5
    528e:	22fd9e8b          	th.muls	t4,s11,a5
    5292:	0ffef713          	zext.b	a4,t4
    5296:	03070f9b          	addiw	t6,a4,48
    529a:	00e5033b          	addw	t1,a0,a4
    529e:	0ffffb13          	zext.b	s6,t6
    52a2:	0ff37c93          	zext.b	s9,t1
    52a6:	01d3be33          	sltu	t3,t2,t4
    52aa:	41cb1c8b          	th.mveqz	s9,s6,t3
    52ae:	01958023          	sb	s9,0(a1)
    52b2:	62ff6263          	bltu	t5,a5,58d6 <_vsnprintf+0x2fc6>
    52b6:	00158b13          	addi	s6,a1,1
    52ba:	05010f13          	addi	t5,sp,80
    52be:	616f0c63          	beq	t5,s6,58d6 <_vsnprintf+0x2fc6>
    52c2:	02fdd333          	divu	t1,s11,a5
    52c6:	8eee                	mv	t4,s11
    52c8:	85da                	mv	a1,s6
    52ca:	22f31e8b          	th.muls	t4,t1,a5
    52ce:	0ffef713          	zext.b	a4,t4
    52d2:	0307029b          	addiw	t0,a4,48
    52d6:	00e50fbb          	addw	t6,a0,a4
    52da:	0ff2fc93          	zext.b	s9,t0
    52de:	0ffffe13          	zext.b	t3,t6
    52e2:	01d3bf33          	sltu	t5,t2,t4
    52e6:	41ec9e0b          	th.mveqz	t3,s9,t5
    52ea:	01cb0023          	sb	t3,0(s6)
    52ee:	5efde463          	bltu	s11,a5,58d6 <_vsnprintf+0x2fc6>
    52f2:	02f35db3          	divu	s11,t1,a5
    52f6:	8e9a                	mv	t4,t1
    52f8:	22fd9e8b          	th.muls	t4,s11,a5
    52fc:	0ffef713          	zext.b	a4,t4
    5300:	0307029b          	addiw	t0,a4,48
    5304:	00e50fbb          	addw	t6,a0,a4
    5308:	0ff2fc93          	zext.b	s9,t0
    530c:	0ffffe13          	zext.b	t3,t6
    5310:	01d3bf33          	sltu	t5,t2,t4
    5314:	41ec9e0b          	th.mveqz	t3,s9,t5
    5318:	0815de0b          	th.sbib	t3,(a1),1,0
    531c:	5af36d63          	bltu	t1,a5,58d6 <_vsnprintf+0x2fc6>
    5320:	02fdd333          	divu	t1,s11,a5
    5324:	8eee                	mv	t4,s11
    5326:	002b0593          	addi	a1,s6,2
    532a:	22f31e8b          	th.muls	t4,t1,a5
    532e:	0ffef713          	zext.b	a4,t4
    5332:	0307029b          	addiw	t0,a4,48
    5336:	00e50fbb          	addw	t6,a0,a4
    533a:	0ff2fc93          	zext.b	s9,t0
    533e:	0ffffe13          	zext.b	t3,t6
    5342:	01d3bf33          	sltu	t5,t2,t4
    5346:	41ec9e0b          	th.mveqz	t3,s9,t5
    534a:	01cb0123          	sb	t3,2(s6)
    534e:	58fde463          	bltu	s11,a5,58d6 <_vsnprintf+0x2fc6>
    5352:	02f35db3          	divu	s11,t1,a5
    5356:	8e9a                	mv	t4,t1
    5358:	003b0593          	addi	a1,s6,3
    535c:	22fd9e8b          	th.muls	t4,s11,a5
    5360:	0ffef713          	zext.b	a4,t4
    5364:	0307029b          	addiw	t0,a4,48
    5368:	00e50fbb          	addw	t6,a0,a4
    536c:	0ff2fc93          	zext.b	s9,t0
    5370:	0ffffe13          	zext.b	t3,t6
    5374:	01d3bf33          	sltu	t5,t2,t4
    5378:	41ec9e0b          	th.mveqz	t3,s9,t5
    537c:	01cb01a3          	sb	t3,3(s6)
    5380:	54f36b63          	bltu	t1,a5,58d6 <_vsnprintf+0x2fc6>
    5384:	004b0593          	addi	a1,s6,4
    5388:	8f6e                	mv	t5,s11
    538a:	bdfd                	j	5288 <_vsnprintf+0x2978>
    538c:	410607b3          	sub	a5,a2,a6
    5390:	002e7c93          	andi	s9,t3,2
    5394:	00178713          	addi	a4,a5,1
    5398:	8672                	mv	a2,t3
    539a:	000c9463          	bnez	s9,53a2 <_vsnprintf+0x2a92>
    539e:	7d20106f          	j	6b70 <_vsnprintf+0x4260>
    53a2:	000e8463          	beqz	t4,53aa <_vsnprintf+0x2a9a>
    53a6:	30e0206f          	j	76b4 <_vsnprintf+0x4da4>
    53aa:	02000e13          	li	t3,32
    53ae:	4d09                	li	s10,2
    53b0:	01c70463          	beq	a4,t3,53b8 <_vsnprintf+0x2aa8>
    53b4:	7510206f          	j	8304 <_vsnprintf+0x59f4>
    53b8:	6e02                	ld	t3,0(sp)
    53ba:	02000713          	li	a4,32
    53be:	01c70bb3          	add	s7,a4,t3
    53c2:	00e80c33          	add	s8,a6,a4
    53c6:	8b1d                	andi	a4,a4,7
    53c8:	01780b33          	add	s6,a6,s7
    53cc:	c761                	beqz	a4,5494 <_vsnprintf+0x2b84>
    53ce:	4505                	li	a0,1
    53d0:	0aa70363          	beq	a4,a0,5476 <_vsnprintf+0x2b66>
    53d4:	4309                	li	t1,2
    53d6:	08670563          	beq	a4,t1,5460 <_vsnprintf+0x2b50>
    53da:	428d                	li	t0,3
    53dc:	06570763          	beq	a4,t0,544a <_vsnprintf+0x2b3a>
    53e0:	4391                	li	t2,4
    53e2:	04770963          	beq	a4,t2,5434 <_vsnprintf+0x2b24>
    53e6:	4f15                	li	t5,5
    53e8:	03e70b63          	beq	a4,t5,541e <_vsnprintf+0x2b0e>
    53ec:	4699                	li	a3,6
    53ee:	00d70d63          	beq	a4,a3,5408 <_vsnprintf+0x2af8>
    53f2:	418b0633          	sub	a2,s6,s8
    53f6:	89fc450b          	th.lbuib	a0,(s8),-1,0
    53fa:	ec46                	sd	a7,24(sp)
    53fc:	f042                	sd	a6,32(sp)
    53fe:	86a6                	mv	a3,s1
    5400:	85ca                	mv	a1,s2
    5402:	9402                	jalr	s0
    5404:	68e2                	ld	a7,24(sp)
    5406:	7802                	ld	a6,32(sp)
    5408:	418b0633          	sub	a2,s6,s8
    540c:	89fc450b          	th.lbuib	a0,(s8),-1,0
    5410:	ec46                	sd	a7,24(sp)
    5412:	f042                	sd	a6,32(sp)
    5414:	86a6                	mv	a3,s1
    5416:	85ca                	mv	a1,s2
    5418:	9402                	jalr	s0
    541a:	68e2                	ld	a7,24(sp)
    541c:	7802                	ld	a6,32(sp)
    541e:	418b0633          	sub	a2,s6,s8
    5422:	89fc450b          	th.lbuib	a0,(s8),-1,0
    5426:	ec46                	sd	a7,24(sp)
    5428:	f042                	sd	a6,32(sp)
    542a:	86a6                	mv	a3,s1
    542c:	85ca                	mv	a1,s2
    542e:	9402                	jalr	s0
    5430:	68e2                	ld	a7,24(sp)
    5432:	7802                	ld	a6,32(sp)
    5434:	418b0633          	sub	a2,s6,s8
    5438:	89fc450b          	th.lbuib	a0,(s8),-1,0
    543c:	ec46                	sd	a7,24(sp)
    543e:	f042                	sd	a6,32(sp)
    5440:	86a6                	mv	a3,s1
    5442:	85ca                	mv	a1,s2
    5444:	9402                	jalr	s0
    5446:	68e2                	ld	a7,24(sp)
    5448:	7802                	ld	a6,32(sp)
    544a:	418b0633          	sub	a2,s6,s8
    544e:	89fc450b          	th.lbuib	a0,(s8),-1,0
    5452:	ec46                	sd	a7,24(sp)
    5454:	f042                	sd	a6,32(sp)
    5456:	86a6                	mv	a3,s1
    5458:	85ca                	mv	a1,s2
    545a:	9402                	jalr	s0
    545c:	68e2                	ld	a7,24(sp)
    545e:	7802                	ld	a6,32(sp)
    5460:	418b0633          	sub	a2,s6,s8
    5464:	89fc450b          	th.lbuib	a0,(s8),-1,0
    5468:	ec46                	sd	a7,24(sp)
    546a:	f042                	sd	a6,32(sp)
    546c:	86a6                	mv	a3,s1
    546e:	85ca                	mv	a1,s2
    5470:	9402                	jalr	s0
    5472:	68e2                	ld	a7,24(sp)
    5474:	7802                	ld	a6,32(sp)
    5476:	418b0633          	sub	a2,s6,s8
    547a:	89fc450b          	th.lbuib	a0,(s8),-1,0
    547e:	fd01588b          	th.sdd	a7,a6,(sp),2,4
    5482:	86a6                	mv	a3,s1
    5484:	85ca                	mv	a1,s2
    5486:	ec5e                	sd	s7,24(sp)
    5488:	9402                	jalr	s0
    548a:	fd01488b          	th.ldd	a7,a6,(sp),2,4
    548e:	6e62                	ld	t3,24(sp)
    5490:	09880963          	beq	a6,s8,5522 <_vsnprintf+0x2c12>
    5494:	ec6a                	sd	s10,24(sp)
    5496:	f046                	sd	a7,32(sp)
    5498:	8d42                	mv	s10,a6
    549a:	8ae2                	mv	s5,s8
    549c:	89fac50b          	th.lbuib	a0,(s5),-1,0
    54a0:	418b0633          	sub	a2,s6,s8
    54a4:	86a6                	mv	a3,s1
    54a6:	85ca                	mv	a1,s2
    54a8:	9402                	jalr	s0
    54aa:	8ce2                	mv	s9,s8
    54ac:	89ecc50b          	th.lbuib	a0,(s9),-2,0
    54b0:	415b0633          	sub	a2,s6,s5
    54b4:	86a6                	mv	a3,s1
    54b6:	85ca                	mv	a1,s2
    54b8:	9402                	jalr	s0
    54ba:	8ae2                	mv	s5,s8
    54bc:	89dac50b          	th.lbuib	a0,(s5),-3,0
    54c0:	419b0633          	sub	a2,s6,s9
    54c4:	86a6                	mv	a3,s1
    54c6:	85ca                	mv	a1,s2
    54c8:	9402                	jalr	s0
    54ca:	8ce2                	mv	s9,s8
    54cc:	89ccc50b          	th.lbuib	a0,(s9),-4,0
    54d0:	415b0633          	sub	a2,s6,s5
    54d4:	86a6                	mv	a3,s1
    54d6:	85ca                	mv	a1,s2
    54d8:	9402                	jalr	s0
    54da:	8ae2                	mv	s5,s8
    54dc:	89bac50b          	th.lbuib	a0,(s5),-5,0
    54e0:	419b0633          	sub	a2,s6,s9
    54e4:	86a6                	mv	a3,s1
    54e6:	85ca                	mv	a1,s2
    54e8:	9402                	jalr	s0
    54ea:	8ce2                	mv	s9,s8
    54ec:	89acc50b          	th.lbuib	a0,(s9),-6,0
    54f0:	415b0633          	sub	a2,s6,s5
    54f4:	86a6                	mv	a3,s1
    54f6:	85ca                	mv	a1,s2
    54f8:	9402                	jalr	s0
    54fa:	8ae2                	mv	s5,s8
    54fc:	899ac50b          	th.lbuib	a0,(s5),-7,0
    5500:	86a6                	mv	a3,s1
    5502:	419b0633          	sub	a2,s6,s9
    5506:	85ca                	mv	a1,s2
    5508:	9402                	jalr	s0
    550a:	898c450b          	th.lbuib	a0,(s8),-8,0
    550e:	86a6                	mv	a3,s1
    5510:	415b0633          	sub	a2,s6,s5
    5514:	85ca                	mv	a1,s2
    5516:	9402                	jalr	s0
    5518:	f98d11e3          	bne	s10,s8,549a <_vsnprintf+0x2b8a>
    551c:	6d62                	ld	s10,24(sp)
    551e:	7882                	ld	a7,32(sp)
    5520:	8e5e                	mv	t3,s7
    5522:	000d1463          	bnez	s10,552a <_vsnprintf+0x2c1a>
    5526:	ca7fe06f          	j	41cc <_vsnprintf+0x18bc>
    552a:	7c08bc0b          	th.extu	s8,a7,31,0
    552e:	6882                	ld	a7,0(sp)
    5530:	411e0ab3          	sub	s5,t3,a7
    5534:	018ae463          	bltu	s5,s8,553c <_vsnprintf+0x2c2c>
    5538:	c95fe06f          	j	41cc <_vsnprintf+0x18bc>
    553c:	fffac593          	not	a1,s5
    5540:	01858633          	add	a2,a1,s8
    5544:	00767b93          	andi	s7,a2,7
    5548:	86a6                	mv	a3,s1
    554a:	8672                	mv	a2,t3
    554c:	85ca                	mv	a1,s2
    554e:	02000513          	li	a0,32
    5552:	e072                	sd	t3,0(sp)
    5554:	001e0b13          	addi	s6,t3,1
    5558:	001a8d13          	addi	s10,s5,1
    555c:	9402                	jalr	s0
    555e:	6782                	ld	a5,0(sp)
    5560:	018d6463          	bltu	s10,s8,5568 <_vsnprintf+0x2c58>
    5564:	c7dfe06f          	j	41e0 <_vsnprintf+0x18d0>
    5568:	0a0b8263          	beqz	s7,560c <_vsnprintf+0x2cfc>
    556c:	4e85                	li	t4,1
    556e:	09db8363          	beq	s7,t4,55f4 <_vsnprintf+0x2ce4>
    5572:	4709                	li	a4,2
    5574:	06eb8863          	beq	s7,a4,55e4 <_vsnprintf+0x2cd4>
    5578:	450d                	li	a0,3
    557a:	04ab8d63          	beq	s7,a0,55d4 <_vsnprintf+0x2cc4>
    557e:	4311                	li	t1,4
    5580:	046b8263          	beq	s7,t1,55c4 <_vsnprintf+0x2cb4>
    5584:	4295                	li	t0,5
    5586:	025b8763          	beq	s7,t0,55b4 <_vsnprintf+0x2ca4>
    558a:	4399                	li	t2,6
    558c:	007b8c63          	beq	s7,t2,55a4 <_vsnprintf+0x2c94>
    5590:	865a                	mv	a2,s6
    5592:	86a6                	mv	a3,s1
    5594:	85ca                	mv	a1,s2
    5596:	02000513          	li	a0,32
    559a:	00278b13          	addi	s6,a5,2
    559e:	002a8d13          	addi	s10,s5,2
    55a2:	9402                	jalr	s0
    55a4:	865a                	mv	a2,s6
    55a6:	86a6                	mv	a3,s1
    55a8:	85ca                	mv	a1,s2
    55aa:	02000513          	li	a0,32
    55ae:	0b05                	addi	s6,s6,1
    55b0:	9402                	jalr	s0
    55b2:	0d05                	addi	s10,s10,1
    55b4:	865a                	mv	a2,s6
    55b6:	86a6                	mv	a3,s1
    55b8:	85ca                	mv	a1,s2
    55ba:	02000513          	li	a0,32
    55be:	0b05                	addi	s6,s6,1
    55c0:	9402                	jalr	s0
    55c2:	0d05                	addi	s10,s10,1
    55c4:	865a                	mv	a2,s6
    55c6:	86a6                	mv	a3,s1
    55c8:	85ca                	mv	a1,s2
    55ca:	02000513          	li	a0,32
    55ce:	0b05                	addi	s6,s6,1
    55d0:	9402                	jalr	s0
    55d2:	0d05                	addi	s10,s10,1
    55d4:	865a                	mv	a2,s6
    55d6:	86a6                	mv	a3,s1
    55d8:	85ca                	mv	a1,s2
    55da:	02000513          	li	a0,32
    55de:	0b05                	addi	s6,s6,1
    55e0:	9402                	jalr	s0
    55e2:	0d05                	addi	s10,s10,1
    55e4:	865a                	mv	a2,s6
    55e6:	86a6                	mv	a3,s1
    55e8:	85ca                	mv	a1,s2
    55ea:	02000513          	li	a0,32
    55ee:	0b05                	addi	s6,s6,1
    55f0:	9402                	jalr	s0
    55f2:	0d05                	addi	s10,s10,1
    55f4:	865a                	mv	a2,s6
    55f6:	86a6                	mv	a3,s1
    55f8:	85ca                	mv	a1,s2
    55fa:	02000513          	li	a0,32
    55fe:	0d05                	addi	s10,s10,1
    5600:	0b05                	addi	s6,s6,1
    5602:	9402                	jalr	s0
    5604:	018d6463          	bltu	s10,s8,560c <_vsnprintf+0x2cfc>
    5608:	bd9fe06f          	j	41e0 <_vsnprintf+0x18d0>
    560c:	865a                	mv	a2,s6
    560e:	86a6                	mv	a3,s1
    5610:	85ca                	mv	a1,s2
    5612:	02000513          	li	a0,32
    5616:	9402                	jalr	s0
    5618:	001b0c93          	addi	s9,s6,1
    561c:	8666                	mv	a2,s9
    561e:	86a6                	mv	a3,s1
    5620:	85ca                	mv	a1,s2
    5622:	02000513          	li	a0,32
    5626:	9402                	jalr	s0
    5628:	002b0b93          	addi	s7,s6,2
    562c:	865e                	mv	a2,s7
    562e:	86a6                	mv	a3,s1
    5630:	85ca                	mv	a1,s2
    5632:	02000513          	li	a0,32
    5636:	9402                	jalr	s0
    5638:	003b0a93          	addi	s5,s6,3
    563c:	8656                	mv	a2,s5
    563e:	86a6                	mv	a3,s1
    5640:	85ca                	mv	a1,s2
    5642:	02000513          	li	a0,32
    5646:	9402                	jalr	s0
    5648:	004b0c93          	addi	s9,s6,4
    564c:	8666                	mv	a2,s9
    564e:	86a6                	mv	a3,s1
    5650:	85ca                	mv	a1,s2
    5652:	02000513          	li	a0,32
    5656:	9402                	jalr	s0
    5658:	005b0a93          	addi	s5,s6,5
    565c:	86a6                	mv	a3,s1
    565e:	8656                	mv	a2,s5
    5660:	85ca                	mv	a1,s2
    5662:	02000513          	li	a0,32
    5666:	9402                	jalr	s0
    5668:	006b0b93          	addi	s7,s6,6
    566c:	86a6                	mv	a3,s1
    566e:	865e                	mv	a2,s7
    5670:	85ca                	mv	a1,s2
    5672:	02000513          	li	a0,32
    5676:	9402                	jalr	s0
    5678:	007b0c93          	addi	s9,s6,7
    567c:	86a6                	mv	a3,s1
    567e:	8666                	mv	a2,s9
    5680:	85ca                	mv	a1,s2
    5682:	02000513          	li	a0,32
    5686:	0d21                	addi	s10,s10,8
    5688:	0b21                	addi	s6,s6,8
    568a:	9402                	jalr	s0
    568c:	f98d60e3          	bltu	s10,s8,560c <_vsnprintf+0x2cfc>
    5690:	b51fe06f          	j	41e0 <_vsnprintf+0x18d0>
    5694:	e056                	sd	s5,0(sp)
    5696:	b53fe06f          	j	41e8 <_vsnprintf+0x18d8>
    569a:	000c8463          	beqz	s9,56a2 <_vsnprintf+0x2d92>
    569e:	7620106f          	j	6e00 <_vsnprintf+0x44f0>
    56a2:	47c1                	li	a5,16
    56a4:	48bd                	li	a7,15
    56a6:	8d3e                	mv	s10,a5
    56a8:	b4f9                	j	5176 <_vsnprintf+0x2866>
    56aa:	40000a93          	li	s5,1024
    56ae:	011be463          	bltu	s7,a7,56b6 <_vsnprintf+0x2da6>
    56b2:	0950206f          	j	7f46 <_vsnprintf+0x5636>
    56b6:	6e82                	ld	t4,0(sp)
    56b8:	fff8851b          	addiw	a0,a7,-1
    56bc:	41750bbb          	subw	s7,a0,s7
    56c0:	7c0bbe0b          	th.extu	t3,s7,31,0
    56c4:	001e8b13          	addi	s6,t4,1
    56c8:	007e7c93          	andi	s9,t3,7
    56cc:	016e07b3          	add	a5,t3,s6
    56d0:	000c9463          	bnez	s9,56d8 <_vsnprintf+0x2dc8>
    56d4:	6e00106f          	j	6db4 <_vsnprintf+0x44a4>
    56d8:	6602                	ld	a2,0(sp)
    56da:	ec46                	sd	a7,24(sp)
    56dc:	f03e                	sd	a5,32(sp)
    56de:	e05a                	sd	s6,0(sp)
    56e0:	86a6                	mv	a3,s1
    56e2:	85ca                	mv	a1,s2
    56e4:	02000513          	li	a0,32
    56e8:	9402                	jalr	s0
    56ea:	4285                	li	t0,1
    56ec:	68e2                	ld	a7,24(sp)
    56ee:	7782                	ld	a5,32(sp)
    56f0:	865a                	mv	a2,s6
    56f2:	0b05                	addi	s6,s6,1
    56f4:	005c9463          	bne	s9,t0,56fc <_vsnprintf+0x2dec>
    56f8:	6bc0106f          	j	6db4 <_vsnprintf+0x44a4>
    56fc:	4689                	li	a3,2
    56fe:	08dc8763          	beq	s9,a3,578c <_vsnprintf+0x2e7c>
    5702:	430d                	li	t1,3
    5704:	066c8863          	beq	s9,t1,5774 <_vsnprintf+0x2e64>
    5708:	4391                	li	t2,4
    570a:	047c8963          	beq	s9,t2,575c <_vsnprintf+0x2e4c>
    570e:	4f15                	li	t5,5
    5710:	03ec8a63          	beq	s9,t5,5744 <_vsnprintf+0x2e34>
    5714:	4599                	li	a1,6
    5716:	00bc8b63          	beq	s9,a1,572c <_vsnprintf+0x2e1c>
    571a:	e05a                	sd	s6,0(sp)
    571c:	86a6                	mv	a3,s1
    571e:	85ca                	mv	a1,s2
    5720:	02000513          	li	a0,32
    5724:	9402                	jalr	s0
    5726:	68e2                	ld	a7,24(sp)
    5728:	7782                	ld	a5,32(sp)
    572a:	0b05                	addi	s6,s6,1
    572c:	6602                	ld	a2,0(sp)
    572e:	ec46                	sd	a7,24(sp)
    5730:	f03e                	sd	a5,32(sp)
    5732:	e05a                	sd	s6,0(sp)
    5734:	86a6                	mv	a3,s1
    5736:	85ca                	mv	a1,s2
    5738:	02000513          	li	a0,32
    573c:	9402                	jalr	s0
    573e:	68e2                	ld	a7,24(sp)
    5740:	7782                	ld	a5,32(sp)
    5742:	0b05                	addi	s6,s6,1
    5744:	6602                	ld	a2,0(sp)
    5746:	ec46                	sd	a7,24(sp)
    5748:	f03e                	sd	a5,32(sp)
    574a:	e05a                	sd	s6,0(sp)
    574c:	86a6                	mv	a3,s1
    574e:	85ca                	mv	a1,s2
    5750:	02000513          	li	a0,32
    5754:	9402                	jalr	s0
    5756:	68e2                	ld	a7,24(sp)
    5758:	7782                	ld	a5,32(sp)
    575a:	0b05                	addi	s6,s6,1
    575c:	6602                	ld	a2,0(sp)
    575e:	ec46                	sd	a7,24(sp)
    5760:	f03e                	sd	a5,32(sp)
    5762:	e05a                	sd	s6,0(sp)
    5764:	86a6                	mv	a3,s1
    5766:	85ca                	mv	a1,s2
    5768:	02000513          	li	a0,32
    576c:	9402                	jalr	s0
    576e:	68e2                	ld	a7,24(sp)
    5770:	7782                	ld	a5,32(sp)
    5772:	0b05                	addi	s6,s6,1
    5774:	6602                	ld	a2,0(sp)
    5776:	ec46                	sd	a7,24(sp)
    5778:	f03e                	sd	a5,32(sp)
    577a:	e05a                	sd	s6,0(sp)
    577c:	86a6                	mv	a3,s1
    577e:	85ca                	mv	a1,s2
    5780:	02000513          	li	a0,32
    5784:	9402                	jalr	s0
    5786:	68e2                	ld	a7,24(sp)
    5788:	7782                	ld	a5,32(sp)
    578a:	0b05                	addi	s6,s6,1
    578c:	6602                	ld	a2,0(sp)
    578e:	ec46                	sd	a7,24(sp)
    5790:	f03e                	sd	a5,32(sp)
    5792:	86a6                	mv	a3,s1
    5794:	85ca                	mv	a1,s2
    5796:	02000513          	li	a0,32
    579a:	9402                	jalr	s0
    579c:	8bda                	mv	s7,s6
    579e:	7c82                	ld	s9,32(sp)
    57a0:	0b05                	addi	s6,s6,1
    57a2:	f056                	sd	s5,32(sp)
    57a4:	a895                	j	5818 <_vsnprintf+0x2f08>
    57a6:	865a                	mv	a2,s6
    57a8:	86a6                	mv	a3,s1
    57aa:	85ca                	mv	a1,s2
    57ac:	02000513          	li	a0,32
    57b0:	9402                	jalr	s0
    57b2:	001b0b93          	addi	s7,s6,1
    57b6:	865e                	mv	a2,s7
    57b8:	86a6                	mv	a3,s1
    57ba:	85ca                	mv	a1,s2
    57bc:	02000513          	li	a0,32
    57c0:	9402                	jalr	s0
    57c2:	002b0a93          	addi	s5,s6,2
    57c6:	8656                	mv	a2,s5
    57c8:	86a6                	mv	a3,s1
    57ca:	85ca                	mv	a1,s2
    57cc:	02000513          	li	a0,32
    57d0:	9402                	jalr	s0
    57d2:	003b0b93          	addi	s7,s6,3
    57d6:	865e                	mv	a2,s7
    57d8:	86a6                	mv	a3,s1
    57da:	85ca                	mv	a1,s2
    57dc:	02000513          	li	a0,32
    57e0:	9402                	jalr	s0
    57e2:	004b0a93          	addi	s5,s6,4
    57e6:	8656                	mv	a2,s5
    57e8:	86a6                	mv	a3,s1
    57ea:	85ca                	mv	a1,s2
    57ec:	02000513          	li	a0,32
    57f0:	9402                	jalr	s0
    57f2:	005b0b93          	addi	s7,s6,5
    57f6:	865e                	mv	a2,s7
    57f8:	86a6                	mv	a3,s1
    57fa:	85ca                	mv	a1,s2
    57fc:	02000513          	li	a0,32
    5800:	9402                	jalr	s0
    5802:	006b0a93          	addi	s5,s6,6
    5806:	86a6                	mv	a3,s1
    5808:	8656                	mv	a2,s5
    580a:	85ca                	mv	a1,s2
    580c:	02000513          	li	a0,32
    5810:	007b0b93          	addi	s7,s6,7
    5814:	9402                	jalr	s0
    5816:	0b21                	addi	s6,s6,8
    5818:	865e                	mv	a2,s7
    581a:	86a6                	mv	a3,s1
    581c:	85ca                	mv	a1,s2
    581e:	02000513          	li	a0,32
    5822:	9402                	jalr	s0
    5824:	f99b11e3          	bne	s6,s9,57a6 <_vsnprintf+0x2e96>
    5828:	68e2                	ld	a7,24(sp)
    582a:	7a82                	ld	s5,32(sp)
    582c:	000d4503          	lbu	a0,0(s10)
    5830:	e05a                	sd	s6,0(sp)
    5832:	00188b9b          	addiw	s7,a7,1
    5836:	e119                	bnez	a0,583c <_vsnprintf+0x2f2c>
    5838:	9b1fe06f          	j	41e8 <_vsnprintf+0x18d8>
    583c:	000a9463          	bnez	s5,5844 <_vsnprintf+0x2f34>
    5840:	b79fe06f          	j	43b8 <_vsnprintf+0x1aa8>
    5844:	4a81                	li	s5,0
    5846:	e8cfd06f          	j	2ed2 <_vsnprintf+0x5c2>
    584a:	400b7b93          	andi	s7,s6,1024
    584e:	000b8463          	beqz	s7,5856 <_vsnprintf+0x2f46>
    5852:	1aa0206f          	j	79fc <_vsnprintf+0x50ec>
    5856:	002b7e13          	andi	t3,s6,2
    585a:	000e0463          	beqz	t3,5862 <_vsnprintf+0x2f52>
    585e:	845fd06f          	j	30a2 <_vsnprintf+0x792>
    5862:	4a81                	li	s5,0
    5864:	e51be9e3          	bltu	s7,a7,56b6 <_vsnprintf+0x2da6>
    5868:	6c82                	ld	s9,0(sp)
    586a:	2b85                	addiw	s7,s7,1
    586c:	c119                	beqz	a0,5872 <_vsnprintf+0x2f62>
    586e:	b4bfe06f          	j	43b8 <_vsnprintf+0x1aa8>
    5872:	977fe06f          	j	41e8 <_vsnprintf+0x18d8>
    5876:	0001                	nop
    5878:	fff7081b          	addiw	a6,a4,-1
    587c:	41f7180b          	th.mveqz	a6,a4,t6
    5880:	41c887bb          	subw	a5,a7,t3
    5884:	011e32b3          	sltu	t0,t3,a7
    5888:	002b7313          	andi	t1,s6,2
    588c:	42e8170b          	th.mvnez	a4,a6,a4
    5890:	4050178b          	th.mveqz	a5,zero,t0
    5894:	8c0303e3          	beqz	t1,515a <_vsnprintf+0x284a>
    5898:	4a89                	li	s5,2
    589a:	4781                	li	a5,0
    589c:	bceff06f          	j	4c6a <_vsnprintf+0x235a>
    58a0:	fefb7593          	andi	a1,s6,-17
    58a4:	06900613          	li	a2,105
    58a8:	8f5a                	mv	t5,s6
    58aa:	2581                	sext.w	a1,a1
    58ac:	00c50463          	beq	a0,a2,58b4 <_vsnprintf+0x2fa4>
    58b0:	1f50106f          	j	72a4 <_vsnprintf+0x4994>
    58b4:	400b7713          	andi	a4,s6,1024
    58b8:	c319                	beqz	a4,58be <_vsnprintf+0x2fae>
    58ba:	f25fe06f          	j	47de <_vsnprintf+0x1ece>
    58be:	200f7813          	andi	a6,t5,512
    58c2:	56081963          	bnez	a6,5e34 <_vsnprintf+0x3524>
    58c6:	100f7e93          	andi	t4,t5,256
    58ca:	000e9463          	bnez	t4,58d2 <_vsnprintf+0x2fc2>
    58ce:	f33fe06f          	j	4800 <_vsnprintf+0x1ef0>
    58d2:	c70fe06f          	j	3d42 <_vsnprintf+0x1432>
    58d6:	410587b3          	sub	a5,a1,a6
    58da:	00267393          	andi	t2,a2,2
    58de:	00178d93          	addi	s11,a5,1
    58e2:	85b2                	mv	a1,a2
    58e4:	00039463          	bnez	t2,58ec <_vsnprintf+0x2fdc>
    58e8:	7840106f          	j	706c <_vsnprintf+0x475c>
    58ec:	000d0463          	beqz	s10,58f4 <_vsnprintf+0x2fe4>
    58f0:	1840206f          	j	7a74 <_vsnprintf+0x5164>
    58f4:	02000c13          	li	s8,32
    58f8:	4d09                	li	s10,2
    58fa:	018d8463          	beq	s11,s8,5902 <_vsnprintf+0x2ff2>
    58fe:	1990206f          	j	8296 <_vsnprintf+0x5986>
    5902:	6682                	ld	a3,0(sp)
    5904:	02000d93          	li	s11,32
    5908:	00dd8bb3          	add	s7,s11,a3
    590c:	007df713          	andi	a4,s11,7
    5910:	01b80c33          	add	s8,a6,s11
    5914:	01780b33          	add	s6,a6,s7
    5918:	c379                	beqz	a4,59de <_vsnprintf+0x30ce>
    591a:	4f85                	li	t6,1
    591c:	0bf70363          	beq	a4,t6,59c2 <_vsnprintf+0x30b2>
    5920:	4689                	li	a3,2
    5922:	08d70563          	beq	a4,a3,59ac <_vsnprintf+0x309c>
    5926:	4f0d                	li	t5,3
    5928:	07e70763          	beq	a4,t5,5996 <_vsnprintf+0x3086>
    592c:	4791                	li	a5,4
    592e:	04f70963          	beq	a4,a5,5980 <_vsnprintf+0x3070>
    5932:	4395                	li	t2,5
    5934:	02770b63          	beq	a4,t2,596a <_vsnprintf+0x305a>
    5938:	4319                	li	t1,6
    593a:	00670d63          	beq	a4,t1,5954 <_vsnprintf+0x3044>
    593e:	418b0633          	sub	a2,s6,s8
    5942:	89fc450b          	th.lbuib	a0,(s8),-1,0
    5946:	ec46                	sd	a7,24(sp)
    5948:	f042                	sd	a6,32(sp)
    594a:	86a6                	mv	a3,s1
    594c:	85ca                	mv	a1,s2
    594e:	9402                	jalr	s0
    5950:	68e2                	ld	a7,24(sp)
    5952:	7802                	ld	a6,32(sp)
    5954:	418b0633          	sub	a2,s6,s8
    5958:	89fc450b          	th.lbuib	a0,(s8),-1,0
    595c:	ec46                	sd	a7,24(sp)
    595e:	f042                	sd	a6,32(sp)
    5960:	86a6                	mv	a3,s1
    5962:	85ca                	mv	a1,s2
    5964:	9402                	jalr	s0
    5966:	68e2                	ld	a7,24(sp)
    5968:	7802                	ld	a6,32(sp)
    596a:	418b0633          	sub	a2,s6,s8
    596e:	89fc450b          	th.lbuib	a0,(s8),-1,0
    5972:	ec46                	sd	a7,24(sp)
    5974:	f042                	sd	a6,32(sp)
    5976:	86a6                	mv	a3,s1
    5978:	85ca                	mv	a1,s2
    597a:	9402                	jalr	s0
    597c:	68e2                	ld	a7,24(sp)
    597e:	7802                	ld	a6,32(sp)
    5980:	418b0633          	sub	a2,s6,s8
    5984:	89fc450b          	th.lbuib	a0,(s8),-1,0
    5988:	ec46                	sd	a7,24(sp)
    598a:	f042                	sd	a6,32(sp)
    598c:	86a6                	mv	a3,s1
    598e:	85ca                	mv	a1,s2
    5990:	9402                	jalr	s0
    5992:	68e2                	ld	a7,24(sp)
    5994:	7802                	ld	a6,32(sp)
    5996:	418b0633          	sub	a2,s6,s8
    599a:	89fc450b          	th.lbuib	a0,(s8),-1,0
    599e:	ec46                	sd	a7,24(sp)
    59a0:	f042                	sd	a6,32(sp)
    59a2:	86a6                	mv	a3,s1
    59a4:	85ca                	mv	a1,s2
    59a6:	9402                	jalr	s0
    59a8:	68e2                	ld	a7,24(sp)
    59aa:	7802                	ld	a6,32(sp)
    59ac:	418b0633          	sub	a2,s6,s8
    59b0:	89fc450b          	th.lbuib	a0,(s8),-1,0
    59b4:	ec46                	sd	a7,24(sp)
    59b6:	f042                	sd	a6,32(sp)
    59b8:	86a6                	mv	a3,s1
    59ba:	85ca                	mv	a1,s2
    59bc:	9402                	jalr	s0
    59be:	68e2                	ld	a7,24(sp)
    59c0:	7802                	ld	a6,32(sp)
    59c2:	418b0633          	sub	a2,s6,s8
    59c6:	89fc450b          	th.lbuib	a0,(s8),-1,0
    59ca:	ec46                	sd	a7,24(sp)
    59cc:	f042                	sd	a6,32(sp)
    59ce:	86a6                	mv	a3,s1
    59d0:	85ca                	mv	a1,s2
    59d2:	9402                	jalr	s0
    59d4:	68e2                	ld	a7,24(sp)
    59d6:	7802                	ld	a6,32(sp)
    59d8:	8dde                	mv	s11,s7
    59da:	09880b63          	beq	a6,s8,5a70 <_vsnprintf+0x3160>
    59de:	ec56                	sd	s5,24(sp)
    59e0:	f06a                	sd	s10,32(sp)
    59e2:	8ac2                	mv	s5,a6
    59e4:	8d46                	mv	s10,a7
    59e6:	8ce2                	mv	s9,s8
    59e8:	89fcc50b          	th.lbuib	a0,(s9),-1,0
    59ec:	418b0633          	sub	a2,s6,s8
    59f0:	86a6                	mv	a3,s1
    59f2:	85ca                	mv	a1,s2
    59f4:	9402                	jalr	s0
    59f6:	8de2                	mv	s11,s8
    59f8:	89edc50b          	th.lbuib	a0,(s11),-2,0
    59fc:	419b0633          	sub	a2,s6,s9
    5a00:	86a6                	mv	a3,s1
    5a02:	85ca                	mv	a1,s2
    5a04:	9402                	jalr	s0
    5a06:	8ce2                	mv	s9,s8
    5a08:	89dcc50b          	th.lbuib	a0,(s9),-3,0
    5a0c:	41bb0633          	sub	a2,s6,s11
    5a10:	86a6                	mv	a3,s1
    5a12:	85ca                	mv	a1,s2
    5a14:	9402                	jalr	s0
    5a16:	8de2                	mv	s11,s8
    5a18:	89cdc50b          	th.lbuib	a0,(s11),-4,0
    5a1c:	419b0633          	sub	a2,s6,s9
    5a20:	86a6                	mv	a3,s1
    5a22:	85ca                	mv	a1,s2
    5a24:	9402                	jalr	s0
    5a26:	8ce2                	mv	s9,s8
    5a28:	89bcc50b          	th.lbuib	a0,(s9),-5,0
    5a2c:	41bb0633          	sub	a2,s6,s11
    5a30:	86a6                	mv	a3,s1
    5a32:	85ca                	mv	a1,s2
    5a34:	9402                	jalr	s0
    5a36:	8de2                	mv	s11,s8
    5a38:	89adc50b          	th.lbuib	a0,(s11),-6,0
    5a3c:	419b0633          	sub	a2,s6,s9
    5a40:	86a6                	mv	a3,s1
    5a42:	85ca                	mv	a1,s2
    5a44:	9402                	jalr	s0
    5a46:	8ce2                	mv	s9,s8
    5a48:	899cc50b          	th.lbuib	a0,(s9),-7,0
    5a4c:	41bb0633          	sub	a2,s6,s11
    5a50:	86a6                	mv	a3,s1
    5a52:	85ca                	mv	a1,s2
    5a54:	9402                	jalr	s0
    5a56:	898c450b          	th.lbuib	a0,(s8),-8,0
    5a5a:	86a6                	mv	a3,s1
    5a5c:	419b0633          	sub	a2,s6,s9
    5a60:	85ca                	mv	a1,s2
    5a62:	8dde                	mv	s11,s7
    5a64:	9402                	jalr	s0
    5a66:	f98a90e3          	bne	s5,s8,59e6 <_vsnprintf+0x30d6>
    5a6a:	88ea                	mv	a7,s10
    5a6c:	6ae2                	ld	s5,24(sp)
    5a6e:	7d02                	ld	s10,32(sp)
    5a70:	000d1d63          	bnez	s10,5a8a <_vsnprintf+0x317a>
    5a74:	e06e                	sd	s11,0(sp)
    5a76:	8dd6                	mv	s11,s5
    5a78:	f70fe06f          	j	41e8 <_vsnprintf+0x18d8>
    5a7c:	002ffd13          	andi	s10,t6,2
    5a80:	000d1463          	bnez	s10,5a88 <_vsnprintf+0x3178>
    5a84:	72c0206f          	j	81b0 <_vsnprintf+0x58a0>
    5a88:	6d82                	ld	s11,0(sp)
    5a8a:	6e82                	ld	t4,0(sp)
    5a8c:	7c08bc0b          	th.extu	s8,a7,31,0
    5a90:	41dd8d33          	sub	s10,s11,t4
    5a94:	ff8d70e3          	bgeu	s10,s8,5a74 <_vsnprintf+0x3164>
    5a98:	fffd4893          	not	a7,s10
    5a9c:	01888e33          	add	t3,a7,s8
    5aa0:	86a6                	mv	a3,s1
    5aa2:	866e                	mv	a2,s11
    5aa4:	85ca                	mv	a1,s2
    5aa6:	02000513          	li	a0,32
    5aaa:	001d0c93          	addi	s9,s10,1
    5aae:	007e7b93          	andi	s7,t3,7
    5ab2:	001d8b13          	addi	s6,s11,1
    5ab6:	9402                	jalr	s0
    5ab8:	138cf463          	bgeu	s9,s8,5be0 <_vsnprintf+0x32d0>
    5abc:	0a0b8063          	beqz	s7,5b5c <_vsnprintf+0x324c>
    5ac0:	4285                	li	t0,1
    5ac2:	085b8363          	beq	s7,t0,5b48 <_vsnprintf+0x3238>
    5ac6:	4589                	li	a1,2
    5ac8:	06bb8863          	beq	s7,a1,5b38 <_vsnprintf+0x3228>
    5acc:	460d                	li	a2,3
    5ace:	04cb8d63          	beq	s7,a2,5b28 <_vsnprintf+0x3218>
    5ad2:	4511                	li	a0,4
    5ad4:	04ab8263          	beq	s7,a0,5b18 <_vsnprintf+0x3208>
    5ad8:	4715                	li	a4,5
    5ada:	02eb8763          	beq	s7,a4,5b08 <_vsnprintf+0x31f8>
    5ade:	4f99                	li	t6,6
    5ae0:	01fb8c63          	beq	s7,t6,5af8 <_vsnprintf+0x31e8>
    5ae4:	865a                	mv	a2,s6
    5ae6:	86a6                	mv	a3,s1
    5ae8:	85ca                	mv	a1,s2
    5aea:	02000513          	li	a0,32
    5aee:	002d8b13          	addi	s6,s11,2
    5af2:	9402                	jalr	s0
    5af4:	002d0c93          	addi	s9,s10,2
    5af8:	865a                	mv	a2,s6
    5afa:	86a6                	mv	a3,s1
    5afc:	85ca                	mv	a1,s2
    5afe:	02000513          	li	a0,32
    5b02:	0b05                	addi	s6,s6,1
    5b04:	9402                	jalr	s0
    5b06:	0c85                	addi	s9,s9,1
    5b08:	865a                	mv	a2,s6
    5b0a:	86a6                	mv	a3,s1
    5b0c:	85ca                	mv	a1,s2
    5b0e:	02000513          	li	a0,32
    5b12:	0b05                	addi	s6,s6,1
    5b14:	9402                	jalr	s0
    5b16:	0c85                	addi	s9,s9,1
    5b18:	865a                	mv	a2,s6
    5b1a:	86a6                	mv	a3,s1
    5b1c:	85ca                	mv	a1,s2
    5b1e:	02000513          	li	a0,32
    5b22:	0b05                	addi	s6,s6,1
    5b24:	9402                	jalr	s0
    5b26:	0c85                	addi	s9,s9,1
    5b28:	865a                	mv	a2,s6
    5b2a:	86a6                	mv	a3,s1
    5b2c:	85ca                	mv	a1,s2
    5b2e:	02000513          	li	a0,32
    5b32:	0b05                	addi	s6,s6,1
    5b34:	9402                	jalr	s0
    5b36:	0c85                	addi	s9,s9,1
    5b38:	865a                	mv	a2,s6
    5b3a:	86a6                	mv	a3,s1
    5b3c:	85ca                	mv	a1,s2
    5b3e:	02000513          	li	a0,32
    5b42:	0b05                	addi	s6,s6,1
    5b44:	9402                	jalr	s0
    5b46:	0c85                	addi	s9,s9,1
    5b48:	865a                	mv	a2,s6
    5b4a:	86a6                	mv	a3,s1
    5b4c:	85ca                	mv	a1,s2
    5b4e:	02000513          	li	a0,32
    5b52:	0c85                	addi	s9,s9,1
    5b54:	0b05                	addi	s6,s6,1
    5b56:	9402                	jalr	s0
    5b58:	098cf463          	bgeu	s9,s8,5be0 <_vsnprintf+0x32d0>
    5b5c:	865a                	mv	a2,s6
    5b5e:	86a6                	mv	a3,s1
    5b60:	85ca                	mv	a1,s2
    5b62:	02000513          	li	a0,32
    5b66:	9402                	jalr	s0
    5b68:	001b0d93          	addi	s11,s6,1
    5b6c:	866e                	mv	a2,s11
    5b6e:	86a6                	mv	a3,s1
    5b70:	85ca                	mv	a1,s2
    5b72:	02000513          	li	a0,32
    5b76:	9402                	jalr	s0
    5b78:	002b0d13          	addi	s10,s6,2
    5b7c:	866a                	mv	a2,s10
    5b7e:	86a6                	mv	a3,s1
    5b80:	85ca                	mv	a1,s2
    5b82:	02000513          	li	a0,32
    5b86:	9402                	jalr	s0
    5b88:	003b0b93          	addi	s7,s6,3
    5b8c:	865e                	mv	a2,s7
    5b8e:	86a6                	mv	a3,s1
    5b90:	85ca                	mv	a1,s2
    5b92:	02000513          	li	a0,32
    5b96:	9402                	jalr	s0
    5b98:	004b0d93          	addi	s11,s6,4
    5b9c:	866e                	mv	a2,s11
    5b9e:	86a6                	mv	a3,s1
    5ba0:	85ca                	mv	a1,s2
    5ba2:	02000513          	li	a0,32
    5ba6:	9402                	jalr	s0
    5ba8:	005b0b93          	addi	s7,s6,5
    5bac:	86a6                	mv	a3,s1
    5bae:	865e                	mv	a2,s7
    5bb0:	85ca                	mv	a1,s2
    5bb2:	02000513          	li	a0,32
    5bb6:	9402                	jalr	s0
    5bb8:	006b0d13          	addi	s10,s6,6
    5bbc:	86a6                	mv	a3,s1
    5bbe:	866a                	mv	a2,s10
    5bc0:	85ca                	mv	a1,s2
    5bc2:	02000513          	li	a0,32
    5bc6:	9402                	jalr	s0
    5bc8:	007b0d93          	addi	s11,s6,7
    5bcc:	86a6                	mv	a3,s1
    5bce:	866e                	mv	a2,s11
    5bd0:	85ca                	mv	a1,s2
    5bd2:	02000513          	li	a0,32
    5bd6:	0ca1                	addi	s9,s9,8
    5bd8:	0b21                	addi	s6,s6,8
    5bda:	9402                	jalr	s0
    5bdc:	f98ce0e3          	bltu	s9,s8,5b5c <_vsnprintf+0x324c>
    5be0:	e05a                	sd	s6,0(sp)
    5be2:	8dd6                	mv	s11,s5
    5be4:	e04fe06f          	j	41e8 <_vsnprintf+0x18d8>
    5be8:	886e                	mv	a6,s11
    5bea:	78884e8b          	th.ldia	t4,(a6),8,0
    5bee:	240e9963          	bnez	t4,5e40 <_vsnprintf+0x3530>
    5bf2:	002afd93          	andi	s11,s5,2
    5bf6:	000d8463          	beqz	s11,5bfe <_vsnprintf+0x32ee>
    5bfa:	2ae0206f          	j	7ea8 <_vsnprintf+0x5598>
    5bfe:	7c0c3c0b          	th.extu	s8,s8,31,0
    5c02:	4781                	li	a5,0
    5c04:	03010c93          	addi	s9,sp,48
    5c08:	00089463          	bnez	a7,5c10 <_vsnprintf+0x3300>
    5c0c:	5c80206f          	j	81d4 <_vsnprintf+0x58c4>
    5c10:	000c1463          	bnez	s8,5c18 <_vsnprintf+0x3308>
    5c14:	7050206f          	j	8b18 <_vsnprintf+0x6208>
    5c18:	02000a93          	li	s5,32
    5c1c:	40fa8633          	sub	a2,s5,a5
    5c20:	00767393          	andi	t2,a2,7
    5c24:	00fc8bb3          	add	s7,s9,a5
    5c28:	03000e13          	li	t3,48
    5c2c:	06038763          	beqz	t2,5c9a <_vsnprintf+0x338a>
    5c30:	0785                	addi	a5,a5,1
    5c32:	181bde0b          	th.sbia	t3,(s7),1,0
    5c36:	0d87f663          	bgeu	a5,s8,5d02 <_vsnprintf+0x33f2>
    5c3a:	4f85                	li	t6,1
    5c3c:	05f38f63          	beq	t2,t6,5c9a <_vsnprintf+0x338a>
    5c40:	4709                	li	a4,2
    5c42:	04e38763          	beq	t2,a4,5c90 <_vsnprintf+0x3380>
    5c46:	4f0d                	li	t5,3
    5c48:	03e38f63          	beq	t2,t5,5c86 <_vsnprintf+0x3376>
    5c4c:	4d11                	li	s10,4
    5c4e:	03a38763          	beq	t2,s10,5c7c <_vsnprintf+0x336c>
    5c52:	4295                	li	t0,5
    5c54:	00538f63          	beq	t2,t0,5c72 <_vsnprintf+0x3362>
    5c58:	4319                	li	t1,6
    5c5a:	00638763          	beq	t2,t1,5c68 <_vsnprintf+0x3358>
    5c5e:	0785                	addi	a5,a5,1
    5c60:	181bde0b          	th.sbia	t3,(s7),1,0
    5c64:	0987ff63          	bgeu	a5,s8,5d02 <_vsnprintf+0x33f2>
    5c68:	0785                	addi	a5,a5,1
    5c6a:	181bde0b          	th.sbia	t3,(s7),1,0
    5c6e:	0987fa63          	bgeu	a5,s8,5d02 <_vsnprintf+0x33f2>
    5c72:	0785                	addi	a5,a5,1
    5c74:	181bde0b          	th.sbia	t3,(s7),1,0
    5c78:	0987f563          	bgeu	a5,s8,5d02 <_vsnprintf+0x33f2>
    5c7c:	0785                	addi	a5,a5,1
    5c7e:	181bde0b          	th.sbia	t3,(s7),1,0
    5c82:	0987f063          	bgeu	a5,s8,5d02 <_vsnprintf+0x33f2>
    5c86:	0785                	addi	a5,a5,1
    5c88:	181bde0b          	th.sbia	t3,(s7),1,0
    5c8c:	0787fb63          	bgeu	a5,s8,5d02 <_vsnprintf+0x33f2>
    5c90:	0785                	addi	a5,a5,1
    5c92:	181bde0b          	th.sbia	t3,(s7),1,0
    5c96:	0787f663          	bgeu	a5,s8,5d02 <_vsnprintf+0x33f2>
    5c9a:	01579463          	bne	a5,s5,5ca2 <_vsnprintf+0x3392>
    5c9e:	7800106f          	j	741e <_vsnprintf+0x4b0e>
    5ca2:	0785                	addi	a5,a5,1
    5ca4:	01cb8023          	sb	t3,0(s7)
    5ca8:	853e                	mv	a0,a5
    5caa:	0587fc63          	bgeu	a5,s8,5d02 <_vsnprintf+0x33f2>
    5cae:	0785                	addi	a5,a5,1
    5cb0:	01cb80a3          	sb	t3,1(s7)
    5cb4:	0587f763          	bgeu	a5,s8,5d02 <_vsnprintf+0x33f2>
    5cb8:	00250793          	addi	a5,a0,2
    5cbc:	01cb8123          	sb	t3,2(s7)
    5cc0:	0587f163          	bgeu	a5,s8,5d02 <_vsnprintf+0x33f2>
    5cc4:	00350793          	addi	a5,a0,3
    5cc8:	01cb81a3          	sb	t3,3(s7)
    5ccc:	0387fb63          	bgeu	a5,s8,5d02 <_vsnprintf+0x33f2>
    5cd0:	00450793          	addi	a5,a0,4
    5cd4:	01cb8223          	sb	t3,4(s7)
    5cd8:	0387f563          	bgeu	a5,s8,5d02 <_vsnprintf+0x33f2>
    5cdc:	00550793          	addi	a5,a0,5
    5ce0:	01cb82a3          	sb	t3,5(s7)
    5ce4:	0187ff63          	bgeu	a5,s8,5d02 <_vsnprintf+0x33f2>
    5ce8:	00650793          	addi	a5,a0,6
    5cec:	01cb8323          	sb	t3,6(s7)
    5cf0:	0187f963          	bgeu	a5,s8,5d02 <_vsnprintf+0x33f2>
    5cf4:	01cb83a3          	sb	t3,7(s7)
    5cf8:	00750793          	addi	a5,a0,7
    5cfc:	0ba1                	addi	s7,s7,8
    5cfe:	f987eee3          	bltu	a5,s8,5c9a <_vsnprintf+0x338a>
    5d02:	000d9463          	bnez	s11,5d0a <_vsnprintf+0x33fa>
    5d06:	23a0206f          	j	7f40 <_vsnprintf+0x5630>
    5d0a:	7c08b68b          	th.extu	a3,a7,31,0
    5d0e:	00d7e463          	bltu	a5,a3,5d16 <_vsnprintf+0x3406>
    5d12:	2b70206f          	j	87c8 <_vsnprintf+0x5eb8>
    5d16:	02000d93          	li	s11,32
    5d1a:	40fd8ab3          	sub	s5,s11,a5
    5d1e:	007afe13          	andi	t3,s5,7
    5d22:	00fc8633          	add	a2,s9,a5
    5d26:	03000b13          	li	s6,48
    5d2a:	060e0763          	beqz	t3,5d98 <_vsnprintf+0x3488>
    5d2e:	0785                	addi	a5,a5,1
    5d30:	18165b0b          	th.sbia	s6,(a2),1,0
    5d34:	0cd78663          	beq	a5,a3,5e00 <_vsnprintf+0x34f0>
    5d38:	4385                	li	t2,1
    5d3a:	047e0f63          	beq	t3,t2,5d98 <_vsnprintf+0x3488>
    5d3e:	4f89                	li	t6,2
    5d40:	05fe0763          	beq	t3,t6,5d8e <_vsnprintf+0x347e>
    5d44:	470d                	li	a4,3
    5d46:	02ee0f63          	beq	t3,a4,5d84 <_vsnprintf+0x3474>
    5d4a:	4f11                	li	t5,4
    5d4c:	03ee0763          	beq	t3,t5,5d7a <_vsnprintf+0x346a>
    5d50:	4d15                	li	s10,5
    5d52:	01ae0f63          	beq	t3,s10,5d70 <_vsnprintf+0x3460>
    5d56:	4299                	li	t0,6
    5d58:	005e0763          	beq	t3,t0,5d66 <_vsnprintf+0x3456>
    5d5c:	0785                	addi	a5,a5,1
    5d5e:	18165b0b          	th.sbia	s6,(a2),1,0
    5d62:	08d78f63          	beq	a5,a3,5e00 <_vsnprintf+0x34f0>
    5d66:	0785                	addi	a5,a5,1
    5d68:	18165b0b          	th.sbia	s6,(a2),1,0
    5d6c:	08d78a63          	beq	a5,a3,5e00 <_vsnprintf+0x34f0>
    5d70:	0785                	addi	a5,a5,1
    5d72:	18165b0b          	th.sbia	s6,(a2),1,0
    5d76:	08d78563          	beq	a5,a3,5e00 <_vsnprintf+0x34f0>
    5d7a:	0785                	addi	a5,a5,1
    5d7c:	18165b0b          	th.sbia	s6,(a2),1,0
    5d80:	08d78063          	beq	a5,a3,5e00 <_vsnprintf+0x34f0>
    5d84:	0785                	addi	a5,a5,1
    5d86:	18165b0b          	th.sbia	s6,(a2),1,0
    5d8a:	06d78b63          	beq	a5,a3,5e00 <_vsnprintf+0x34f0>
    5d8e:	0785                	addi	a5,a5,1
    5d90:	18165b0b          	th.sbia	s6,(a2),1,0
    5d94:	06d78663          	beq	a5,a3,5e00 <_vsnprintf+0x34f0>
    5d98:	01b79463          	bne	a5,s11,5da0 <_vsnprintf+0x3490>
    5d9c:	6640106f          	j	7400 <_vsnprintf+0x4af0>
    5da0:	00178313          	addi	t1,a5,1
    5da4:	01660023          	sb	s6,0(a2)
    5da8:	04d30c63          	beq	t1,a3,5e00 <_vsnprintf+0x34f0>
    5dac:	00278513          	addi	a0,a5,2
    5db0:	016600a3          	sb	s6,1(a2)
    5db4:	04d50663          	beq	a0,a3,5e00 <_vsnprintf+0x34f0>
    5db8:	00378b93          	addi	s7,a5,3
    5dbc:	01660123          	sb	s6,2(a2)
    5dc0:	04db8063          	beq	s7,a3,5e00 <_vsnprintf+0x34f0>
    5dc4:	00478c13          	addi	s8,a5,4
    5dc8:	016601a3          	sb	s6,3(a2)
    5dcc:	02dc0a63          	beq	s8,a3,5e00 <_vsnprintf+0x34f0>
    5dd0:	00578a93          	addi	s5,a5,5
    5dd4:	01660223          	sb	s6,4(a2)
    5dd8:	02da8463          	beq	s5,a3,5e00 <_vsnprintf+0x34f0>
    5ddc:	00678e13          	addi	t3,a5,6
    5de0:	016602a3          	sb	s6,5(a2)
    5de4:	00de0e63          	beq	t3,a3,5e00 <_vsnprintf+0x34f0>
    5de8:	00778393          	addi	t2,a5,7
    5dec:	01660323          	sb	s6,6(a2)
    5df0:	00d38863          	beq	t2,a3,5e00 <_vsnprintf+0x34f0>
    5df4:	016603a3          	sb	s6,7(a2)
    5df8:	07a1                	addi	a5,a5,8
    5dfa:	0621                	addi	a2,a2,8
    5dfc:	f8d79ee3          	bne	a5,a3,5d98 <_vsnprintf+0x3488>
    5e00:	02000793          	li	a5,32
    5e04:	00f69463          	bne	a3,a5,5e0c <_vsnprintf+0x34fc>
    5e08:	5f80106f          	j	7400 <_vsnprintf+0x4af0>
    5e0c:	000ec463          	bltz	t4,5e14 <_vsnprintf+0x3504>
    5e10:	07b0206f          	j	868a <_vsnprintf+0x5d7a>
    5e14:	00268ab3          	add	s5,a3,sp
    5e18:	02d00513          	li	a0,45
    5e1c:	02aa8823          	sb	a0,48(s5)
    5e20:	0035fe13          	andi	t3,a1,3
    5e24:	00168c13          	addi	s8,a3,1
    5e28:	380e06e3          	beqz	t3,69b4 <_vsnprintf+0x40a4>
    5e2c:	8dc2                	mv	s11,a6
    5e2e:	4b01                	li	s6,0
    5e30:	6802                	ld	a6,0(sp)
    5e32:	aaa5                	j	5faa <_vsnprintf+0x369a>
    5e34:	886e                	mv	a6,s11
    5e36:	78884e8b          	th.ldia	t4,(a6),8,0
    5e3a:	4b81                	li	s7,0
    5e3c:	000e8863          	beqz	t4,5e4c <_vsnprintf+0x353c>
    5e40:	43fedd93          	srai	s11,t4,0x3f
    5e44:	01ddc533          	xor	a0,s11,t4
    5e48:	41b50bb3          	sub	s7,a0,s11
    5e4c:	46a9                	li	a3,10
    5e4e:	02dbfb33          	remu	s6,s7,a3
    5e52:	03010c93          	addi	s9,sp,48
    5e56:	4d25                	li	s10,9
    5e58:	87e6                	mv	a5,s9
    5e5a:	030b0a9b          	addiw	s5,s6,48
    5e5e:	03510823          	sb	s5,48(sp)
    5e62:	02dbd533          	divu	a0,s7,a3
    5e66:	117d7d63          	bgeu	s10,s7,5f80 <_vsnprintf+0x3670>
    5e6a:	03110793          	addi	a5,sp,49
    5e6e:	02d57333          	remu	t1,a0,a3
    5e72:	03030e1b          	addiw	t3,t1,48
    5e76:	01c78023          	sb	t3,0(a5)
    5e7a:	02d55633          	divu	a2,a0,a3
    5e7e:	10ad7163          	bgeu	s10,a0,5f80 <_vsnprintf+0x3670>
    5e82:	0001                	nop
    5e84:	00000013          	nop
    5e88:	00178293          	addi	t0,a5,1
    5e8c:	05010f93          	addi	t6,sp,80
    5e90:	0e5f8863          	beq	t6,t0,5f80 <_vsnprintf+0x3670>
    5e94:	8796                	mv	a5,t0
    5e96:	02d673b3          	remu	t2,a2,a3
    5e9a:	0303871b          	addiw	a4,t2,48
    5e9e:	00e28023          	sb	a4,0(t0)
    5ea2:	02d65f33          	divu	t5,a2,a3
    5ea6:	0ccd7d63          	bgeu	s10,a2,5f80 <_vsnprintf+0x3670>
    5eaa:	02df7333          	remu	t1,t5,a3
    5eae:	03030d9b          	addiw	s11,t1,48
    5eb2:	0817dd8b          	th.sbib	s11,(a5),1,0
    5eb6:	02df5533          	divu	a0,t5,a3
    5eba:	0ded7363          	bgeu	s10,t5,5f80 <_vsnprintf+0x3670>
    5ebe:	00228793          	addi	a5,t0,2
    5ec2:	02d57bb3          	remu	s7,a0,a3
    5ec6:	030b8b1b          	addiw	s6,s7,48
    5eca:	01628123          	sb	s6,2(t0)
    5ece:	02d55ab3          	divu	s5,a0,a3
    5ed2:	0aad7763          	bgeu	s10,a0,5f80 <_vsnprintf+0x3670>
    5ed6:	00328793          	addi	a5,t0,3
    5eda:	02dafe33          	remu	t3,s5,a3
    5ede:	030e061b          	addiw	a2,t3,48
    5ee2:	00c281a3          	sb	a2,3(t0)
    5ee6:	02dadfb3          	divu	t6,s5,a3
    5eea:	095d7b63          	bgeu	s10,s5,5f80 <_vsnprintf+0x3670>
    5eee:	00428793          	addi	a5,t0,4
    5ef2:	02dff3b3          	remu	t2,t6,a3
    5ef6:	0303871b          	addiw	a4,t2,48
    5efa:	00e28223          	sb	a4,4(t0)
    5efe:	02dfdf33          	divu	t5,t6,a3
    5f02:	07fd7f63          	bgeu	s10,t6,5f80 <_vsnprintf+0x3670>
    5f06:	00528793          	addi	a5,t0,5
    5f0a:	02df7333          	remu	t1,t5,a3
    5f0e:	03030d9b          	addiw	s11,t1,48
    5f12:	01b282a3          	sb	s11,5(t0)
    5f16:	02df5533          	divu	a0,t5,a3
    5f1a:	07ed7363          	bgeu	s10,t5,5f80 <_vsnprintf+0x3670>
    5f1e:	00628793          	addi	a5,t0,6
    5f22:	02d57bb3          	remu	s7,a0,a3
    5f26:	030b8b1b          	addiw	s6,s7,48
    5f2a:	01628323          	sb	s6,6(t0)
    5f2e:	02d55ab3          	divu	s5,a0,a3
    5f32:	04ad7763          	bgeu	s10,a0,5f80 <_vsnprintf+0x3670>
    5f36:	00728793          	addi	a5,t0,7
    5f3a:	02dafe33          	remu	t3,s5,a3
    5f3e:	030e061b          	addiw	a2,t3,48
    5f42:	00c283a3          	sb	a2,7(t0)
    5f46:	02dadfb3          	divu	t6,s5,a3
    5f4a:	035d7b63          	bgeu	s10,s5,5f80 <_vsnprintf+0x3670>
    5f4e:	00828793          	addi	a5,t0,8
    5f52:	02dff3b3          	remu	t2,t6,a3
    5f56:	0303871b          	addiw	a4,t2,48
    5f5a:	00e28423          	sb	a4,8(t0)
    5f5e:	02dfdf33          	divu	t5,t6,a3
    5f62:	01fd7f63          	bgeu	s10,t6,5f80 <_vsnprintf+0x3670>
    5f66:	00928793          	addi	a5,t0,9
    5f6a:	857a                	mv	a0,t5
    5f6c:	02df7333          	remu	t1,t5,a3
    5f70:	03030e1b          	addiw	t3,t1,48
    5f74:	01c78023          	sb	t3,0(a5)
    5f78:	02d55633          	divu	a2,a0,a3
    5f7c:	f0ad66e3          	bltu	s10,a0,5e88 <_vsnprintf+0x3578>
    5f80:	419787b3          	sub	a5,a5,s9
    5f84:	0025fb13          	andi	s6,a1,2
    5f88:	0785                	addi	a5,a5,1
    5f8a:	86ae                	mv	a3,a1
    5f8c:	1e0b04e3          	beqz	s6,6974 <_vsnprintf+0x4064>
    5f90:	02000c13          	li	s8,32
    5f94:	4b09                	li	s6,2
    5f96:	01878463          	beq	a5,s8,5f9e <_vsnprintf+0x368e>
    5f9a:	1b50106f          	j	794e <_vsnprintf+0x503e>
    5f9e:	8dc2                	mv	s11,a6
    5fa0:	04f14503          	lbu	a0,79(sp)
    5fa4:	6802                	ld	a6,0(sp)
    5fa6:	02000c13          	li	s8,32
    5faa:	018c8d33          	add	s10,s9,s8
    5fae:	01880bb3          	add	s7,a6,s8
    5fb2:	fffcc813          	not	a6,s9
    5fb6:	01a802b3          	add	t0,a6,s10
    5fba:	0072f313          	andi	t1,t0,7
    5fbe:	017c8c33          	add	s8,s9,s7
    5fc2:	00031463          	bnez	t1,5fca <_vsnprintf+0x36ba>
    5fc6:	2e80106f          	j	72ae <_vsnprintf+0x499e>
    5fca:	41ac0633          	sub	a2,s8,s10
    5fce:	ec46                	sd	a7,24(sp)
    5fd0:	f01a                	sd	t1,32(sp)
    5fd2:	86a6                	mv	a3,s1
    5fd4:	85ca                	mv	a1,s2
    5fd6:	9402                	jalr	s0
    5fd8:	68e2                	ld	a7,24(sp)
    5fda:	7e02                	ld	t3,32(sp)
    5fdc:	4a85                	li	s5,1
    5fde:	1d7d                	addi	s10,s10,-1
    5fe0:	fffd4503          	lbu	a0,-1(s10)
    5fe4:	015e1463          	bne	t3,s5,5fec <_vsnprintf+0x36dc>
    5fe8:	2c60106f          	j	72ae <_vsnprintf+0x499e>
    5fec:	4609                	li	a2,2
    5fee:	06ce0f63          	beq	t3,a2,606c <_vsnprintf+0x375c>
    5ff2:	438d                	li	t2,3
    5ff4:	067e0263          	beq	t3,t2,6058 <_vsnprintf+0x3748>
    5ff8:	4791                	li	a5,4
    5ffa:	04fe0563          	beq	t3,a5,6044 <_vsnprintf+0x3734>
    5ffe:	4e95                	li	t4,5
    6000:	03de0863          	beq	t3,t4,6030 <_vsnprintf+0x3720>
    6004:	4599                	li	a1,6
    6006:	00be0b63          	beq	t3,a1,601c <_vsnprintf+0x370c>
    600a:	41ac0633          	sub	a2,s8,s10
    600e:	86a6                	mv	a3,s1
    6010:	85ca                	mv	a1,s2
    6012:	9402                	jalr	s0
    6014:	68e2                	ld	a7,24(sp)
    6016:	ffed4503          	lbu	a0,-2(s10)
    601a:	1d7d                	addi	s10,s10,-1
    601c:	41ac0633          	sub	a2,s8,s10
    6020:	ec46                	sd	a7,24(sp)
    6022:	86a6                	mv	a3,s1
    6024:	85ca                	mv	a1,s2
    6026:	9402                	jalr	s0
    6028:	68e2                	ld	a7,24(sp)
    602a:	ffed4503          	lbu	a0,-2(s10)
    602e:	1d7d                	addi	s10,s10,-1
    6030:	41ac0633          	sub	a2,s8,s10
    6034:	ec46                	sd	a7,24(sp)
    6036:	86a6                	mv	a3,s1
    6038:	85ca                	mv	a1,s2
    603a:	9402                	jalr	s0
    603c:	68e2                	ld	a7,24(sp)
    603e:	ffed4503          	lbu	a0,-2(s10)
    6042:	1d7d                	addi	s10,s10,-1
    6044:	41ac0633          	sub	a2,s8,s10
    6048:	ec46                	sd	a7,24(sp)
    604a:	86a6                	mv	a3,s1
    604c:	85ca                	mv	a1,s2
    604e:	9402                	jalr	s0
    6050:	68e2                	ld	a7,24(sp)
    6052:	ffed4503          	lbu	a0,-2(s10)
    6056:	1d7d                	addi	s10,s10,-1
    6058:	41ac0633          	sub	a2,s8,s10
    605c:	ec46                	sd	a7,24(sp)
    605e:	86a6                	mv	a3,s1
    6060:	85ca                	mv	a1,s2
    6062:	9402                	jalr	s0
    6064:	68e2                	ld	a7,24(sp)
    6066:	ffed4503          	lbu	a0,-2(s10)
    606a:	1d7d                	addi	s10,s10,-1
    606c:	41ac0633          	sub	a2,s8,s10
    6070:	86a6                	mv	a3,s1
    6072:	85ca                	mv	a1,s2
    6074:	ec46                	sd	a7,24(sp)
    6076:	9402                	jalr	s0
    6078:	1d7d                	addi	s10,s10,-1
    607a:	f05a                	sd	s6,32(sp)
    607c:	fffd4503          	lbu	a0,-1(s10)
    6080:	a895                	j	60f4 <_vsnprintf+0x37e4>
    6082:	8b6a                	mv	s6,s10
    6084:	40ac0633          	sub	a2,s8,a0
    6088:	89eb450b          	th.lbuib	a0,(s6),-2,0
    608c:	86a6                	mv	a3,s1
    608e:	85ca                	mv	a1,s2
    6090:	9402                	jalr	s0
    6092:	8aea                	mv	s5,s10
    6094:	89dac50b          	th.lbuib	a0,(s5),-3,0
    6098:	416c0633          	sub	a2,s8,s6
    609c:	86a6                	mv	a3,s1
    609e:	85ca                	mv	a1,s2
    60a0:	9402                	jalr	s0
    60a2:	8b6a                	mv	s6,s10
    60a4:	89cb450b          	th.lbuib	a0,(s6),-4,0
    60a8:	415c0633          	sub	a2,s8,s5
    60ac:	86a6                	mv	a3,s1
    60ae:	85ca                	mv	a1,s2
    60b0:	9402                	jalr	s0
    60b2:	8aea                	mv	s5,s10
    60b4:	89bac50b          	th.lbuib	a0,(s5),-5,0
    60b8:	416c0633          	sub	a2,s8,s6
    60bc:	86a6                	mv	a3,s1
    60be:	85ca                	mv	a1,s2
    60c0:	9402                	jalr	s0
    60c2:	8b6a                	mv	s6,s10
    60c4:	89ab450b          	th.lbuib	a0,(s6),-6,0
    60c8:	415c0633          	sub	a2,s8,s5
    60cc:	86a6                	mv	a3,s1
    60ce:	85ca                	mv	a1,s2
    60d0:	9402                	jalr	s0
    60d2:	8aea                	mv	s5,s10
    60d4:	899ac50b          	th.lbuib	a0,(s5),-7,0
    60d8:	86a6                	mv	a3,s1
    60da:	416c0633          	sub	a2,s8,s6
    60de:	85ca                	mv	a1,s2
    60e0:	9402                	jalr	s0
    60e2:	898d450b          	th.lbuib	a0,(s10),-8,0
    60e6:	86a6                	mv	a3,s1
    60e8:	415c0633          	sub	a2,s8,s5
    60ec:	85ca                	mv	a1,s2
    60ee:	9402                	jalr	s0
    60f0:	fffd4503          	lbu	a0,-1(s10)
    60f4:	86a6                	mv	a3,s1
    60f6:	41ac0633          	sub	a2,s8,s10
    60fa:	85ca                	mv	a1,s2
    60fc:	9402                	jalr	s0
    60fe:	fffd0513          	addi	a0,s10,-1
    6102:	f8ac90e3          	bne	s9,a0,6082 <_vsnprintf+0x3772>
    6106:	68e2                	ld	a7,24(sp)
    6108:	7b02                	ld	s6,32(sp)
    610a:	8e5e                	mv	t3,s7
    610c:	000b1463          	bnez	s6,6114 <_vsnprintf+0x3804>
    6110:	8bcfe06f          	j	41cc <_vsnprintf+0x18bc>
    6114:	7c08bc0b          	th.extu	s8,a7,31,0
    6118:	6882                	ld	a7,0(sp)
    611a:	411e0ab3          	sub	s5,t3,a7
    611e:	018ae463          	bltu	s5,s8,6126 <_vsnprintf+0x3816>
    6122:	8aafe06f          	j	41cc <_vsnprintf+0x18bc>
    6126:	fffac693          	not	a3,s5
    612a:	01868fb3          	add	t6,a3,s8
    612e:	8672                	mv	a2,t3
    6130:	86a6                	mv	a3,s1
    6132:	85ca                	mv	a1,s2
    6134:	02000513          	li	a0,32
    6138:	e072                	sd	t3,0(sp)
    613a:	007ffb93          	andi	s7,t6,7
    613e:	001e0b13          	addi	s6,t3,1
    6142:	001a8c93          	addi	s9,s5,1
    6146:	9402                	jalr	s0
    6148:	6f02                	ld	t5,0(sp)
    614a:	018ce463          	bltu	s9,s8,6152 <_vsnprintf+0x3842>
    614e:	892fe06f          	j	41e0 <_vsnprintf+0x18d0>
    6152:	0a0b8263          	beqz	s7,61f6 <_vsnprintf+0x38e6>
    6156:	4705                	li	a4,1
    6158:	08eb8363          	beq	s7,a4,61de <_vsnprintf+0x38ce>
    615c:	4809                	li	a6,2
    615e:	070b8863          	beq	s7,a6,61ce <_vsnprintf+0x38be>
    6162:	428d                	li	t0,3
    6164:	045b8d63          	beq	s7,t0,61be <_vsnprintf+0x38ae>
    6168:	4311                	li	t1,4
    616a:	046b8263          	beq	s7,t1,61ae <_vsnprintf+0x389e>
    616e:	4e15                	li	t3,5
    6170:	03cb8763          	beq	s7,t3,619e <_vsnprintf+0x388e>
    6174:	4619                	li	a2,6
    6176:	00cb8c63          	beq	s7,a2,618e <_vsnprintf+0x387e>
    617a:	865a                	mv	a2,s6
    617c:	86a6                	mv	a3,s1
    617e:	85ca                	mv	a1,s2
    6180:	02000513          	li	a0,32
    6184:	002f0b13          	addi	s6,t5,2
    6188:	002a8c93          	addi	s9,s5,2
    618c:	9402                	jalr	s0
    618e:	865a                	mv	a2,s6
    6190:	86a6                	mv	a3,s1
    6192:	85ca                	mv	a1,s2
    6194:	02000513          	li	a0,32
    6198:	0b05                	addi	s6,s6,1
    619a:	9402                	jalr	s0
    619c:	0c85                	addi	s9,s9,1
    619e:	865a                	mv	a2,s6
    61a0:	86a6                	mv	a3,s1
    61a2:	85ca                	mv	a1,s2
    61a4:	02000513          	li	a0,32
    61a8:	0b05                	addi	s6,s6,1
    61aa:	9402                	jalr	s0
    61ac:	0c85                	addi	s9,s9,1
    61ae:	865a                	mv	a2,s6
    61b0:	86a6                	mv	a3,s1
    61b2:	85ca                	mv	a1,s2
    61b4:	02000513          	li	a0,32
    61b8:	0b05                	addi	s6,s6,1
    61ba:	9402                	jalr	s0
    61bc:	0c85                	addi	s9,s9,1
    61be:	865a                	mv	a2,s6
    61c0:	86a6                	mv	a3,s1
    61c2:	85ca                	mv	a1,s2
    61c4:	02000513          	li	a0,32
    61c8:	0b05                	addi	s6,s6,1
    61ca:	9402                	jalr	s0
    61cc:	0c85                	addi	s9,s9,1
    61ce:	865a                	mv	a2,s6
    61d0:	86a6                	mv	a3,s1
    61d2:	85ca                	mv	a1,s2
    61d4:	02000513          	li	a0,32
    61d8:	0b05                	addi	s6,s6,1
    61da:	9402                	jalr	s0
    61dc:	0c85                	addi	s9,s9,1
    61de:	865a                	mv	a2,s6
    61e0:	86a6                	mv	a3,s1
    61e2:	85ca                	mv	a1,s2
    61e4:	02000513          	li	a0,32
    61e8:	0c85                	addi	s9,s9,1
    61ea:	0b05                	addi	s6,s6,1
    61ec:	9402                	jalr	s0
    61ee:	018ce463          	bltu	s9,s8,61f6 <_vsnprintf+0x38e6>
    61f2:	feffd06f          	j	41e0 <_vsnprintf+0x18d0>
    61f6:	865a                	mv	a2,s6
    61f8:	86a6                	mv	a3,s1
    61fa:	85ca                	mv	a1,s2
    61fc:	02000513          	li	a0,32
    6200:	9402                	jalr	s0
    6202:	001b0d13          	addi	s10,s6,1
    6206:	866a                	mv	a2,s10
    6208:	86a6                	mv	a3,s1
    620a:	85ca                	mv	a1,s2
    620c:	02000513          	li	a0,32
    6210:	9402                	jalr	s0
    6212:	002b0b93          	addi	s7,s6,2
    6216:	865e                	mv	a2,s7
    6218:	86a6                	mv	a3,s1
    621a:	85ca                	mv	a1,s2
    621c:	02000513          	li	a0,32
    6220:	9402                	jalr	s0
    6222:	003b0a93          	addi	s5,s6,3
    6226:	8656                	mv	a2,s5
    6228:	86a6                	mv	a3,s1
    622a:	85ca                	mv	a1,s2
    622c:	02000513          	li	a0,32
    6230:	9402                	jalr	s0
    6232:	004b0d13          	addi	s10,s6,4
    6236:	866a                	mv	a2,s10
    6238:	86a6                	mv	a3,s1
    623a:	85ca                	mv	a1,s2
    623c:	02000513          	li	a0,32
    6240:	9402                	jalr	s0
    6242:	005b0a93          	addi	s5,s6,5
    6246:	86a6                	mv	a3,s1
    6248:	8656                	mv	a2,s5
    624a:	85ca                	mv	a1,s2
    624c:	02000513          	li	a0,32
    6250:	9402                	jalr	s0
    6252:	006b0b93          	addi	s7,s6,6
    6256:	86a6                	mv	a3,s1
    6258:	865e                	mv	a2,s7
    625a:	85ca                	mv	a1,s2
    625c:	02000513          	li	a0,32
    6260:	9402                	jalr	s0
    6262:	007b0d13          	addi	s10,s6,7
    6266:	86a6                	mv	a3,s1
    6268:	866a                	mv	a2,s10
    626a:	85ca                	mv	a1,s2
    626c:	02000513          	li	a0,32
    6270:	0ca1                	addi	s9,s9,8
    6272:	0b21                	addi	s6,s6,8
    6274:	9402                	jalr	s0
    6276:	f98ce0e3          	bltu	s9,s8,61f6 <_vsnprintf+0x38e6>
    627a:	f67fd06f          	j	41e0 <_vsnprintf+0x18d0>
    627e:	0001                	nop
    6280:	5c088be3          	beqz	a7,7056 <_vsnprintf+0x4746>
    6284:	001aff93          	andi	t6,s5,1
    6288:	000f9463          	bnez	t6,6290 <_vsnprintf+0x3980>
    628c:	3d10106f          	j	7e5c <_vsnprintf+0x554c>
    6290:	000e4463          	bltz	t3,6298 <_vsnprintf+0x3988>
    6294:	07a0206f          	j	830e <_vsnprintf+0x59fe>
    6298:	7c0c3c0b          	th.extu	s8,s8,31,0
    629c:	38fd                	addiw	a7,a7,-1
    629e:	0187e463          	bltu	a5,s8,62a6 <_vsnprintf+0x3996>
    62a2:	0d70206f          	j	8b78 <_vsnprintf+0x6268>
    62a6:	02000393          	li	t2,32
    62aa:	40f38f33          	sub	t5,t2,a5
    62ae:	007f7313          	andi	t1,t5,7
    62b2:	00fb86b3          	add	a3,s7,a5
    62b6:	03000b13          	li	s6,48
    62ba:	06030763          	beqz	t1,6328 <_vsnprintf+0x3a18>
    62be:	0785                	addi	a5,a5,1
    62c0:	1816db0b          	th.sbia	s6,(a3),1,0
    62c4:	0d87f463          	bgeu	a5,s8,638c <_vsnprintf+0x3a7c>
    62c8:	4805                	li	a6,1
    62ca:	05030f63          	beq	t1,a6,6328 <_vsnprintf+0x3a18>
    62ce:	4e89                	li	t4,2
    62d0:	05d30763          	beq	t1,t4,631e <_vsnprintf+0x3a0e>
    62d4:	450d                	li	a0,3
    62d6:	02a30f63          	beq	t1,a0,6314 <_vsnprintf+0x3a04>
    62da:	4611                	li	a2,4
    62dc:	02c30763          	beq	t1,a2,630a <_vsnprintf+0x39fa>
    62e0:	4c95                	li	s9,5
    62e2:	01930f63          	beq	t1,s9,6300 <_vsnprintf+0x39f0>
    62e6:	4719                	li	a4,6
    62e8:	00e30763          	beq	t1,a4,62f6 <_vsnprintf+0x39e6>
    62ec:	0785                	addi	a5,a5,1
    62ee:	1816db0b          	th.sbia	s6,(a3),1,0
    62f2:	0987fd63          	bgeu	a5,s8,638c <_vsnprintf+0x3a7c>
    62f6:	0785                	addi	a5,a5,1
    62f8:	1816db0b          	th.sbia	s6,(a3),1,0
    62fc:	0987f863          	bgeu	a5,s8,638c <_vsnprintf+0x3a7c>
    6300:	0785                	addi	a5,a5,1
    6302:	1816db0b          	th.sbia	s6,(a3),1,0
    6306:	0987f363          	bgeu	a5,s8,638c <_vsnprintf+0x3a7c>
    630a:	0785                	addi	a5,a5,1
    630c:	1816db0b          	th.sbia	s6,(a3),1,0
    6310:	0787fe63          	bgeu	a5,s8,638c <_vsnprintf+0x3a7c>
    6314:	0785                	addi	a5,a5,1
    6316:	1816db0b          	th.sbia	s6,(a3),1,0
    631a:	0787f963          	bgeu	a5,s8,638c <_vsnprintf+0x3a7c>
    631e:	0785                	addi	a5,a5,1
    6320:	1816db0b          	th.sbia	s6,(a3),1,0
    6324:	0787f463          	bgeu	a5,s8,638c <_vsnprintf+0x3a7c>
    6328:	50778ce3          	beq	a5,t2,7040 <_vsnprintf+0x4730>
    632c:	0785                	addi	a5,a5,1
    632e:	01668023          	sb	s6,0(a3)
    6332:	8abe                	mv	s5,a5
    6334:	0587fc63          	bgeu	a5,s8,638c <_vsnprintf+0x3a7c>
    6338:	0785                	addi	a5,a5,1
    633a:	016680a3          	sb	s6,1(a3)
    633e:	0587f763          	bgeu	a5,s8,638c <_vsnprintf+0x3a7c>
    6342:	002a8793          	addi	a5,s5,2
    6346:	01668123          	sb	s6,2(a3)
    634a:	0587f163          	bgeu	a5,s8,638c <_vsnprintf+0x3a7c>
    634e:	003a8793          	addi	a5,s5,3
    6352:	016681a3          	sb	s6,3(a3)
    6356:	0387fb63          	bgeu	a5,s8,638c <_vsnprintf+0x3a7c>
    635a:	004a8793          	addi	a5,s5,4
    635e:	01668223          	sb	s6,4(a3)
    6362:	0387f563          	bgeu	a5,s8,638c <_vsnprintf+0x3a7c>
    6366:	005a8793          	addi	a5,s5,5
    636a:	016682a3          	sb	s6,5(a3)
    636e:	0187ff63          	bgeu	a5,s8,638c <_vsnprintf+0x3a7c>
    6372:	006a8793          	addi	a5,s5,6
    6376:	01668323          	sb	s6,6(a3)
    637a:	0187f963          	bgeu	a5,s8,638c <_vsnprintf+0x3a7c>
    637e:	016683a3          	sb	s6,7(a3)
    6382:	007a8793          	addi	a5,s5,7
    6386:	06a1                	addi	a3,a3,8
    6388:	fb87e0e3          	bltu	a5,s8,6328 <_vsnprintf+0x3a18>
    638c:	0e0f8b63          	beqz	t6,6482 <_vsnprintf+0x3b72>
    6390:	7c08bf8b          	th.extu	t6,a7,31,0
    6394:	01f7e463          	bltu	a5,t6,639c <_vsnprintf+0x3a8c>
    6398:	12d0206f          	j	8cc4 <_vsnprintf+0x63b4>
    639c:	02000293          	li	t0,32
    63a0:	40f28d33          	sub	s10,t0,a5
    63a4:	007d7393          	andi	t2,s10,7
    63a8:	00fb8cb3          	add	s9,s7,a5
    63ac:	03000c13          	li	s8,48
    63b0:	06038763          	beqz	t2,641e <_vsnprintf+0x3b0e>
    63b4:	0785                	addi	a5,a5,1
    63b6:	181cdc0b          	th.sbia	s8,(s9),1,0
    63ba:	0df78463          	beq	a5,t6,6482 <_vsnprintf+0x3b72>
    63be:	4b05                	li	s6,1
    63c0:	05638f63          	beq	t2,s6,641e <_vsnprintf+0x3b0e>
    63c4:	4f09                	li	t5,2
    63c6:	05e38763          	beq	t2,t5,6414 <_vsnprintf+0x3b04>
    63ca:	430d                	li	t1,3
    63cc:	02638f63          	beq	t2,t1,640a <_vsnprintf+0x3afa>
    63d0:	4811                	li	a6,4
    63d2:	03038763          	beq	t2,a6,6400 <_vsnprintf+0x3af0>
    63d6:	4e95                	li	t4,5
    63d8:	01d38f63          	beq	t2,t4,63f6 <_vsnprintf+0x3ae6>
    63dc:	4519                	li	a0,6
    63de:	00a38763          	beq	t2,a0,63ec <_vsnprintf+0x3adc>
    63e2:	0785                	addi	a5,a5,1
    63e4:	181cdc0b          	th.sbia	s8,(s9),1,0
    63e8:	09f78d63          	beq	a5,t6,6482 <_vsnprintf+0x3b72>
    63ec:	0785                	addi	a5,a5,1
    63ee:	181cdc0b          	th.sbia	s8,(s9),1,0
    63f2:	09f78863          	beq	a5,t6,6482 <_vsnprintf+0x3b72>
    63f6:	0785                	addi	a5,a5,1
    63f8:	181cdc0b          	th.sbia	s8,(s9),1,0
    63fc:	09f78363          	beq	a5,t6,6482 <_vsnprintf+0x3b72>
    6400:	0785                	addi	a5,a5,1
    6402:	181cdc0b          	th.sbia	s8,(s9),1,0
    6406:	07f78e63          	beq	a5,t6,6482 <_vsnprintf+0x3b72>
    640a:	0785                	addi	a5,a5,1
    640c:	181cdc0b          	th.sbia	s8,(s9),1,0
    6410:	07f78963          	beq	a5,t6,6482 <_vsnprintf+0x3b72>
    6414:	0785                	addi	a5,a5,1
    6416:	181cdc0b          	th.sbia	s8,(s9),1,0
    641a:	07f78463          	beq	a5,t6,6482 <_vsnprintf+0x3b72>
    641e:	3e578ae3          	beq	a5,t0,7012 <_vsnprintf+0x4702>
    6422:	0785                	addi	a5,a5,1
    6424:	018c8023          	sb	s8,0(s9)
    6428:	863e                	mv	a2,a5
    642a:	05f78c63          	beq	a5,t6,6482 <_vsnprintf+0x3b72>
    642e:	0785                	addi	a5,a5,1
    6430:	018c80a3          	sb	s8,1(s9)
    6434:	05f78763          	beq	a5,t6,6482 <_vsnprintf+0x3b72>
    6438:	00260793          	addi	a5,a2,2
    643c:	018c8123          	sb	s8,2(s9)
    6440:	05f78163          	beq	a5,t6,6482 <_vsnprintf+0x3b72>
    6444:	00360793          	addi	a5,a2,3
    6448:	018c81a3          	sb	s8,3(s9)
    644c:	03f78b63          	beq	a5,t6,6482 <_vsnprintf+0x3b72>
    6450:	00460793          	addi	a5,a2,4
    6454:	018c8223          	sb	s8,4(s9)
    6458:	03f78563          	beq	a5,t6,6482 <_vsnprintf+0x3b72>
    645c:	00560793          	addi	a5,a2,5
    6460:	018c82a3          	sb	s8,5(s9)
    6464:	01f78f63          	beq	a5,t6,6482 <_vsnprintf+0x3b72>
    6468:	00660793          	addi	a5,a2,6
    646c:	018c8323          	sb	s8,6(s9)
    6470:	01f78963          	beq	a5,t6,6482 <_vsnprintf+0x3b72>
    6474:	018c83a3          	sb	s8,7(s9)
    6478:	00760793          	addi	a5,a2,7
    647c:	0ca1                	addi	s9,s9,8
    647e:	fbf790e3          	bne	a5,t6,641e <_vsnprintf+0x3b0e>
    6482:	02000713          	li	a4,32
    6486:	38e786e3          	beq	a5,a4,7012 <_vsnprintf+0x4702>
    648a:	000e4463          	bltz	t3,6492 <_vsnprintf+0x3b82>
    648e:	2530106f          	j	7ee0 <_vsnprintf+0x55d0>
    6492:	00278e33          	add	t3,a5,sp
    6496:	02d00513          	li	a0,45
    649a:	02ae0823          	sb	a0,48(t3)
    649e:	0035f613          	andi	a2,a1,3
    64a2:	00178c13          	addi	s8,a5,1
    64a6:	c219                	beqz	a2,64ac <_vsnprintf+0x3b9c>
    64a8:	57e0206f          	j	8a26 <_vsnprintf+0x6116>
    64ac:	7c08bd0b          	th.extu	s10,a7,31,0
    64b0:	4b01                	li	s6,0
    64b2:	1bac67e3          	bltu	s8,s10,6e60 <_vsnprintf+0x4550>
    64b6:	6302                	ld	t1,0(sp)
    64b8:	02d00513          	li	a0,45
    64bc:	cdafe06f          	j	4996 <_vsnprintf+0x2086>
    64c0:	8f32                	mv	t5,a2
    64c2:	fe367e13          	andi	t3,a2,-29
    64c6:	5c0b98e3          	bnez	s7,7296 <_vsnprintf+0x4986>
    64ca:	4e81                	li	t4,0
    64cc:	ecefd06f          	j	3b9a <_vsnprintf+0x128a>
    64d0:	8aee                	mv	s5,s11
    64d2:	788acd0b          	th.ldia	s10,(s5),8,0
    64d6:	010ffe93          	andi	t4,t6,16
    64da:	000d1963          	bnez	s10,64ec <_vsnprintf+0x3bdc>
    64de:	fefffd93          	andi	s11,t6,-17
    64e2:	000d861b          	sext.w	a2,s11
    64e6:	320b9063          	bnez	s7,6806 <_vsnprintf+0x3ef6>
    64ea:	4e81                	li	t4,0
    64ec:	02fd5333          	divu	t1,s10,a5
    64f0:	83ea                	mv	t2,s10
    64f2:	14563f0b          	th.extu	t5,a2,5,5
    64f6:	ffff0f93          	addi	t6,t5,-1
    64fa:	020ff713          	andi	a4,t6,32
    64fe:	0377051b          	addiw	a0,a4,55
    6502:	4e25                	li	t3,9
    6504:	03010b13          	addi	s6,sp,48
    6508:	85da                	mv	a1,s6
    650a:	22f3138b          	th.muls	t2,t1,a5
    650e:	0ff3fc93          	zext.b	s9,t2
    6512:	030c829b          	addiw	t0,s9,48
    6516:	01950f3b          	addw	t5,a0,s9
    651a:	0ff2fd93          	zext.b	s11,t0
    651e:	0fff7713          	zext.b	a4,t5
    6522:	007e3fb3          	sltu	t6,t3,t2
    6526:	41fd970b          	th.mveqz	a4,s11,t6
    652a:	02e10823          	sb	a4,48(sp)
    652e:	14fd6763          	bltu	s10,a5,667c <_vsnprintf+0x3d6c>
    6532:	03110593          	addi	a1,sp,49
    6536:	829a                	mv	t0,t1
    6538:	02f2dd33          	divu	s10,t0,a5
    653c:	8316                	mv	t1,t0
    653e:	22fd130b          	th.muls	t1,s10,a5
    6542:	0ff37393          	zext.b	t2,t1
    6546:	03038c9b          	addiw	s9,t2,48
    654a:	00750f3b          	addw	t5,a0,t2
    654e:	0ffcfd93          	zext.b	s11,s9
    6552:	0fff7713          	zext.b	a4,t5
    6556:	006e3fb3          	sltu	t6,t3,t1
    655a:	41fd970b          	th.mveqz	a4,s11,t6
    655e:	00e58023          	sb	a4,0(a1)
    6562:	10f2ed63          	bltu	t0,a5,667c <_vsnprintf+0x3d6c>
    6566:	00158c93          	addi	s9,a1,1
    656a:	05010293          	addi	t0,sp,80
    656e:	11928763          	beq	t0,s9,667c <_vsnprintf+0x3d6c>
    6572:	02fd5db3          	divu	s11,s10,a5
    6576:	836a                	mv	t1,s10
    6578:	85e6                	mv	a1,s9
    657a:	22fd930b          	th.muls	t1,s11,a5
    657e:	0ff37f13          	zext.b	t5,t1
    6582:	030f039b          	addiw	t2,t5,48
    6586:	01e5073b          	addw	a4,a0,t5
    658a:	0ff3ff93          	zext.b	t6,t2
    658e:	0ff77f13          	zext.b	t5,a4
    6592:	006e32b3          	sltu	t0,t3,t1
    6596:	405f9f0b          	th.mveqz	t5,t6,t0
    659a:	01ec8023          	sb	t5,0(s9)
    659e:	0cfd6f63          	bltu	s10,a5,667c <_vsnprintf+0x3d6c>
    65a2:	02fddd33          	divu	s10,s11,a5
    65a6:	836e                	mv	t1,s11
    65a8:	22fd130b          	th.muls	t1,s10,a5
    65ac:	0ff37f93          	zext.b	t6,t1
    65b0:	030f839b          	addiw	t2,t6,48
    65b4:	01f5073b          	addw	a4,a0,t6
    65b8:	0ff3ff13          	zext.b	t5,t2
    65bc:	0ff77f93          	zext.b	t6,a4
    65c0:	006e32b3          	sltu	t0,t3,t1
    65c4:	405f1f8b          	th.mveqz	t6,t5,t0
    65c8:	0815df8b          	th.sbib	t6,(a1),1,0
    65cc:	0afde863          	bltu	s11,a5,667c <_vsnprintf+0x3d6c>
    65d0:	02fd5db3          	divu	s11,s10,a5
    65d4:	836a                	mv	t1,s10
    65d6:	002c8593          	addi	a1,s9,2
    65da:	22fd930b          	th.muls	t1,s11,a5
    65de:	0ff37f13          	zext.b	t5,t1
    65e2:	030f039b          	addiw	t2,t5,48
    65e6:	01e5073b          	addw	a4,a0,t5
    65ea:	0ff3ff93          	zext.b	t6,t2
    65ee:	0ff77f13          	zext.b	t5,a4
    65f2:	006e32b3          	sltu	t0,t3,t1
    65f6:	405f9f0b          	th.mveqz	t5,t6,t0
    65fa:	01ec8123          	sb	t5,2(s9)
    65fe:	06fd6f63          	bltu	s10,a5,667c <_vsnprintf+0x3d6c>
    6602:	02fdd2b3          	divu	t0,s11,a5
    6606:	8d6e                	mv	s10,s11
    6608:	003c8593          	addi	a1,s9,3
    660c:	22f29d0b          	th.muls	s10,t0,a5
    6610:	0ffd7313          	zext.b	t1,s10
    6614:	0303039b          	addiw	t2,t1,48
    6618:	0065073b          	addw	a4,a0,t1
    661c:	0ff3ff93          	zext.b	t6,t2
    6620:	0ff77f13          	zext.b	t5,a4
    6624:	01ae3d33          	sltu	s10,t3,s10
    6628:	41af9f0b          	th.mveqz	t5,t6,s10
    662c:	01ec81a3          	sb	t5,3(s9)
    6630:	04fde663          	bltu	s11,a5,667c <_vsnprintf+0x3d6c>
    6634:	004c8593          	addi	a1,s9,4
    6638:	b701                	j	6538 <_vsnprintf+0x3c28>
    663a:	02000e13          	li	t3,32
    663e:	01cc0463          	beq	s8,t3,6646 <_vsnprintf+0x3d36>
    6642:	04c0206f          	j	868e <_vsnprintf+0x5d7e>
    6646:	04f14503          	lbu	a0,79(sp)
    664a:	810fd06f          	j	365a <_vsnprintf+0xd4a>
    664e:	4b89                	li	s7,2
    6650:	4ac1                	li	s5,16
    6652:	02000c93          	li	s9,32
    6656:	019d1463          	bne	s10,s9,665e <_vsnprintf+0x3d4e>
    665a:	fabfd06f          	j	4604 <_vsnprintf+0x1cf4>
    665e:	001d0793          	addi	a5,s10,1
    6662:	9d66                	add	s10,s10,s9
    6664:	002d0e33          	add	t3,s10,sp
    6668:	05800e93          	li	t4,88
    666c:	01de0823          	sb	t4,16(t3)
    6670:	01979463          	bne	a5,s9,6678 <_vsnprintf+0x3d68>
    6674:	f91fd06f          	j	4604 <_vsnprintf+0x1cf4>
    6678:	b21fe06f          	j	5198 <_vsnprintf+0x2888>
    667c:	416585b3          	sub	a1,a1,s6
    6680:	00267793          	andi	a5,a2,2
    6684:	00158d13          	addi	s10,a1,1
    6688:	8e32                	mv	t3,a2
    668a:	60078be3          	beqz	a5,74a0 <_vsnprintf+0x4b90>
    668e:	000e8463          	beqz	t4,6696 <_vsnprintf+0x3d86>
    6692:	4b70106f          	j	8348 <_vsnprintf+0x5a38>
    6696:	02000693          	li	a3,32
    669a:	4809                	li	a6,2
    669c:	00dd0463          	beq	s10,a3,66a4 <_vsnprintf+0x3d94>
    66a0:	7550106f          	j	85f4 <_vsnprintf+0x5ce4>
    66a4:	6382                	ld	t2,0(sp)
    66a6:	8bc2                	mv	s7,a6
    66a8:	02000d13          	li	s10,32
    66ac:	007d0cb3          	add	s9,s10,t2
    66b0:	01ab0c33          	add	s8,s6,s10
    66b4:	007d7d13          	andi	s10,s10,7
    66b8:	019b0db3          	add	s11,s6,s9
    66bc:	0a0d0763          	beqz	s10,676a <_vsnprintf+0x3e5a>
    66c0:	4805                	li	a6,1
    66c2:	090d0763          	beq	s10,a6,6750 <_vsnprintf+0x3e40>
    66c6:	4309                	li	t1,2
    66c8:	066d0b63          	beq	s10,t1,673e <_vsnprintf+0x3e2e>
    66cc:	468d                	li	a3,3
    66ce:	04dd0f63          	beq	s10,a3,672c <_vsnprintf+0x3e1c>
    66d2:	4e11                	li	t3,4
    66d4:	05cd0363          	beq	s10,t3,671a <_vsnprintf+0x3e0a>
    66d8:	4295                	li	t0,5
    66da:	025d0763          	beq	s10,t0,6708 <_vsnprintf+0x3df8>
    66de:	4f99                	li	t6,6
    66e0:	01fd0b63          	beq	s10,t6,66f6 <_vsnprintf+0x3de6>
    66e4:	418d8633          	sub	a2,s11,s8
    66e8:	89fc450b          	th.lbuib	a0,(s8),-1,0
    66ec:	ec46                	sd	a7,24(sp)
    66ee:	86a6                	mv	a3,s1
    66f0:	85ca                	mv	a1,s2
    66f2:	9402                	jalr	s0
    66f4:	68e2                	ld	a7,24(sp)
    66f6:	418d8633          	sub	a2,s11,s8
    66fa:	89fc450b          	th.lbuib	a0,(s8),-1,0
    66fe:	ec46                	sd	a7,24(sp)
    6700:	86a6                	mv	a3,s1
    6702:	85ca                	mv	a1,s2
    6704:	9402                	jalr	s0
    6706:	68e2                	ld	a7,24(sp)
    6708:	418d8633          	sub	a2,s11,s8
    670c:	89fc450b          	th.lbuib	a0,(s8),-1,0
    6710:	ec46                	sd	a7,24(sp)
    6712:	86a6                	mv	a3,s1
    6714:	85ca                	mv	a1,s2
    6716:	9402                	jalr	s0
    6718:	68e2                	ld	a7,24(sp)
    671a:	418d8633          	sub	a2,s11,s8
    671e:	89fc450b          	th.lbuib	a0,(s8),-1,0
    6722:	ec46                	sd	a7,24(sp)
    6724:	86a6                	mv	a3,s1
    6726:	85ca                	mv	a1,s2
    6728:	9402                	jalr	s0
    672a:	68e2                	ld	a7,24(sp)
    672c:	418d8633          	sub	a2,s11,s8
    6730:	89fc450b          	th.lbuib	a0,(s8),-1,0
    6734:	ec46                	sd	a7,24(sp)
    6736:	86a6                	mv	a3,s1
    6738:	85ca                	mv	a1,s2
    673a:	9402                	jalr	s0
    673c:	68e2                	ld	a7,24(sp)
    673e:	418d8633          	sub	a2,s11,s8
    6742:	89fc450b          	th.lbuib	a0,(s8),-1,0
    6746:	ec46                	sd	a7,24(sp)
    6748:	86a6                	mv	a3,s1
    674a:	85ca                	mv	a1,s2
    674c:	9402                	jalr	s0
    674e:	68e2                	ld	a7,24(sp)
    6750:	418d8633          	sub	a2,s11,s8
    6754:	89fc450b          	th.lbuib	a0,(s8),-1,0
    6758:	ec66                	sd	s9,24(sp)
    675a:	f046                	sd	a7,32(sp)
    675c:	86a6                	mv	a3,s1
    675e:	85ca                	mv	a1,s2
    6760:	9402                	jalr	s0
    6762:	63e2                	ld	t2,24(sp)
    6764:	7882                	ld	a7,32(sp)
    6766:	098b0a63          	beq	s6,s8,67fa <_vsnprintf+0x3eea>
    676a:	ec56                	sd	s5,24(sp)
    676c:	f05e                	sd	s7,32(sp)
    676e:	8bc6                	mv	s7,a7
    6770:	8d62                	mv	s10,s8
    6772:	89fd450b          	th.lbuib	a0,(s10),-1,0
    6776:	418d8633          	sub	a2,s11,s8
    677a:	86a6                	mv	a3,s1
    677c:	85ca                	mv	a1,s2
    677e:	9402                	jalr	s0
    6780:	8ae2                	mv	s5,s8
    6782:	89eac50b          	th.lbuib	a0,(s5),-2,0
    6786:	41ad8633          	sub	a2,s11,s10
    678a:	86a6                	mv	a3,s1
    678c:	85ca                	mv	a1,s2
    678e:	9402                	jalr	s0
    6790:	8d62                	mv	s10,s8
    6792:	89dd450b          	th.lbuib	a0,(s10),-3,0
    6796:	415d8633          	sub	a2,s11,s5
    679a:	86a6                	mv	a3,s1
    679c:	85ca                	mv	a1,s2
    679e:	9402                	jalr	s0
    67a0:	8ae2                	mv	s5,s8
    67a2:	89cac50b          	th.lbuib	a0,(s5),-4,0
    67a6:	41ad8633          	sub	a2,s11,s10
    67aa:	86a6                	mv	a3,s1
    67ac:	85ca                	mv	a1,s2
    67ae:	9402                	jalr	s0
    67b0:	8d62                	mv	s10,s8
    67b2:	89bd450b          	th.lbuib	a0,(s10),-5,0
    67b6:	415d8633          	sub	a2,s11,s5
    67ba:	86a6                	mv	a3,s1
    67bc:	85ca                	mv	a1,s2
    67be:	9402                	jalr	s0
    67c0:	8ae2                	mv	s5,s8
    67c2:	89aac50b          	th.lbuib	a0,(s5),-6,0
    67c6:	41ad8633          	sub	a2,s11,s10
    67ca:	86a6                	mv	a3,s1
    67cc:	85ca                	mv	a1,s2
    67ce:	9402                	jalr	s0
    67d0:	8d62                	mv	s10,s8
    67d2:	899d450b          	th.lbuib	a0,(s10),-7,0
    67d6:	86a6                	mv	a3,s1
    67d8:	415d8633          	sub	a2,s11,s5
    67dc:	85ca                	mv	a1,s2
    67de:	9402                	jalr	s0
    67e0:	898c450b          	th.lbuib	a0,(s8),-8,0
    67e4:	86a6                	mv	a3,s1
    67e6:	41ad8633          	sub	a2,s11,s10
    67ea:	85ca                	mv	a1,s2
    67ec:	9402                	jalr	s0
    67ee:	f98b11e3          	bne	s6,s8,6770 <_vsnprintf+0x3e60>
    67f2:	88de                	mv	a7,s7
    67f4:	6ae2                	ld	s5,24(sp)
    67f6:	7b82                	ld	s7,32(sp)
    67f8:	83e6                	mv	t2,s9
    67fa:	000b9d63          	bnez	s7,6814 <_vsnprintf+0x3f04>
    67fe:	e01e                	sd	t2,0(sp)
    6800:	8dd6                	mv	s11,s5
    6802:	9e7fd06f          	j	41e8 <_vsnprintf+0x18d8>
    6806:	002ffe93          	andi	t4,t6,2
    680a:	000e9463          	bnez	t4,6812 <_vsnprintf+0x3f02>
    680e:	37b0106f          	j	8388 <_vsnprintf+0x5a78>
    6812:	6382                	ld	t2,0(sp)
    6814:	6b02                	ld	s6,0(sp)
    6816:	7c08bc0b          	th.extu	s8,a7,31,0
    681a:	41638db3          	sub	s11,t2,s6
    681e:	ff8df0e3          	bgeu	s11,s8,67fe <_vsnprintf+0x3eee>
    6822:	fffdc513          	not	a0,s11
    6826:	018508b3          	add	a7,a0,s8
    682a:	85ca                	mv	a1,s2
    682c:	86a6                	mv	a3,s1
    682e:	861e                	mv	a2,t2
    6830:	02000513          	li	a0,32
    6834:	e01e                	sd	t2,0(sp)
    6836:	0078fb93          	andi	s7,a7,7
    683a:	00138b13          	addi	s6,t2,1
    683e:	001d8c93          	addi	s9,s11,1
    6842:	9402                	jalr	s0
    6844:	6582                	ld	a1,0(sp)
    6846:	b98cfd63          	bgeu	s9,s8,5be0 <_vsnprintf+0x32d0>
    684a:	0a0b8063          	beqz	s7,68ea <_vsnprintf+0x3fda>
    684e:	4705                	li	a4,1
    6850:	08eb8363          	beq	s7,a4,68d6 <_vsnprintf+0x3fc6>
    6854:	4789                	li	a5,2
    6856:	06fb8863          	beq	s7,a5,68c6 <_vsnprintf+0x3fb6>
    685a:	460d                	li	a2,3
    685c:	04cb8d63          	beq	s7,a2,68b6 <_vsnprintf+0x3fa6>
    6860:	4e91                	li	t4,4
    6862:	05db8263          	beq	s7,t4,68a6 <_vsnprintf+0x3f96>
    6866:	4815                	li	a6,5
    6868:	030b8763          	beq	s7,a6,6896 <_vsnprintf+0x3f86>
    686c:	4319                	li	t1,6
    686e:	006b8c63          	beq	s7,t1,6886 <_vsnprintf+0x3f76>
    6872:	865a                	mv	a2,s6
    6874:	86a6                	mv	a3,s1
    6876:	00258b13          	addi	s6,a1,2
    687a:	02000513          	li	a0,32
    687e:	85ca                	mv	a1,s2
    6880:	9402                	jalr	s0
    6882:	002d8c93          	addi	s9,s11,2
    6886:	865a                	mv	a2,s6
    6888:	86a6                	mv	a3,s1
    688a:	85ca                	mv	a1,s2
    688c:	02000513          	li	a0,32
    6890:	0b05                	addi	s6,s6,1
    6892:	9402                	jalr	s0
    6894:	0c85                	addi	s9,s9,1
    6896:	865a                	mv	a2,s6
    6898:	86a6                	mv	a3,s1
    689a:	85ca                	mv	a1,s2
    689c:	02000513          	li	a0,32
    68a0:	0b05                	addi	s6,s6,1
    68a2:	9402                	jalr	s0
    68a4:	0c85                	addi	s9,s9,1
    68a6:	865a                	mv	a2,s6
    68a8:	86a6                	mv	a3,s1
    68aa:	85ca                	mv	a1,s2
    68ac:	02000513          	li	a0,32
    68b0:	0b05                	addi	s6,s6,1
    68b2:	9402                	jalr	s0
    68b4:	0c85                	addi	s9,s9,1
    68b6:	865a                	mv	a2,s6
    68b8:	86a6                	mv	a3,s1
    68ba:	85ca                	mv	a1,s2
    68bc:	02000513          	li	a0,32
    68c0:	0b05                	addi	s6,s6,1
    68c2:	9402                	jalr	s0
    68c4:	0c85                	addi	s9,s9,1
    68c6:	865a                	mv	a2,s6
    68c8:	86a6                	mv	a3,s1
    68ca:	85ca                	mv	a1,s2
    68cc:	02000513          	li	a0,32
    68d0:	0b05                	addi	s6,s6,1
    68d2:	9402                	jalr	s0
    68d4:	0c85                	addi	s9,s9,1
    68d6:	865a                	mv	a2,s6
    68d8:	86a6                	mv	a3,s1
    68da:	85ca                	mv	a1,s2
    68dc:	02000513          	li	a0,32
    68e0:	0c85                	addi	s9,s9,1
    68e2:	0b05                	addi	s6,s6,1
    68e4:	9402                	jalr	s0
    68e6:	af8cfd63          	bgeu	s9,s8,5be0 <_vsnprintf+0x32d0>
    68ea:	865a                	mv	a2,s6
    68ec:	86a6                	mv	a3,s1
    68ee:	85ca                	mv	a1,s2
    68f0:	02000513          	li	a0,32
    68f4:	9402                	jalr	s0
    68f6:	001b0d93          	addi	s11,s6,1
    68fa:	866e                	mv	a2,s11
    68fc:	86a6                	mv	a3,s1
    68fe:	85ca                	mv	a1,s2
    6900:	02000513          	li	a0,32
    6904:	9402                	jalr	s0
    6906:	002b0d13          	addi	s10,s6,2
    690a:	866a                	mv	a2,s10
    690c:	86a6                	mv	a3,s1
    690e:	85ca                	mv	a1,s2
    6910:	02000513          	li	a0,32
    6914:	9402                	jalr	s0
    6916:	003b0b93          	addi	s7,s6,3
    691a:	865e                	mv	a2,s7
    691c:	86a6                	mv	a3,s1
    691e:	85ca                	mv	a1,s2
    6920:	02000513          	li	a0,32
    6924:	9402                	jalr	s0
    6926:	004b0d93          	addi	s11,s6,4
    692a:	866e                	mv	a2,s11
    692c:	86a6                	mv	a3,s1
    692e:	85ca                	mv	a1,s2
    6930:	02000513          	li	a0,32
    6934:	9402                	jalr	s0
    6936:	005b0b93          	addi	s7,s6,5
    693a:	86a6                	mv	a3,s1
    693c:	865e                	mv	a2,s7
    693e:	85ca                	mv	a1,s2
    6940:	02000513          	li	a0,32
    6944:	9402                	jalr	s0
    6946:	006b0d13          	addi	s10,s6,6
    694a:	86a6                	mv	a3,s1
    694c:	866a                	mv	a2,s10
    694e:	85ca                	mv	a1,s2
    6950:	02000513          	li	a0,32
    6954:	9402                	jalr	s0
    6956:	007b0d93          	addi	s11,s6,7
    695a:	86a6                	mv	a3,s1
    695c:	866e                	mv	a2,s11
    695e:	85ca                	mv	a1,s2
    6960:	02000513          	li	a0,32
    6964:	0ca1                	addi	s9,s9,8
    6966:	0b21                	addi	s6,s6,8
    6968:	9402                	jalr	s0
    696a:	f98ce0e3          	bltu	s9,s8,68ea <_vsnprintf+0x3fda>
    696e:	e05a                	sd	s6,0(sp)
    6970:	a72ff06f          	j	5be2 <_vsnprintf+0x32d2>
    6974:	30088be3          	beqz	a7,748a <_vsnprintf+0x4b7a>
    6978:	0016fd93          	andi	s11,a3,1
    697c:	000d8463          	beqz	s11,6984 <_vsnprintf+0x4074>
    6980:	4580106f          	j	7dd8 <_vsnprintf+0x54c8>
    6984:	7c0c3c0b          	th.extu	s8,s8,31,0
    6988:	a987e863          	bltu	a5,s8,5c18 <_vsnprintf+0x3308>
    698c:	02000e13          	li	t3,32
    6990:	27c78ce3          	beq	a5,t3,7408 <_vsnprintf+0x4af8>
    6994:	000ec463          	bltz	t4,699c <_vsnprintf+0x408c>
    6998:	0410106f          	j	81d8 <_vsnprintf+0x58c8>
    699c:	01c78633          	add	a2,a5,t3
    69a0:	03010f93          	addi	t6,sp,48
    69a4:	01f603b3          	add	t2,a2,t6
    69a8:	02d00713          	li	a4,45
    69ac:	00178c13          	addi	s8,a5,1
    69b0:	fee38023          	sb	a4,-32(t2)
    69b4:	7c08bb8b          	th.extu	s7,a7,31,0
    69b8:	8dc2                	mv	s11,a6
    69ba:	4b01                	li	s6,0
    69bc:	017c6463          	bltu	s8,s7,69c4 <_vsnprintf+0x40b4>
    69c0:	6b30106f          	j	8872 <_vsnprintf+0x5f62>
    69c4:	6602                	ld	a2,0(sp)
    69c6:	85ca                	mv	a1,s2
    69c8:	86a6                	mv	a3,s1
    69ca:	40cc0cb3          	sub	s9,s8,a2
    69ce:	fffcc393          	not	t2,s9
    69d2:	40c387b3          	sub	a5,t2,a2
    69d6:	01778eb3          	add	t4,a5,s7
    69da:	ec66                	sd	s9,24(sp)
    69dc:	f046                	sd	a7,32(sp)
    69de:	02000513          	li	a0,32
    69e2:	00160d13          	addi	s10,a2,1
    69e6:	007efa93          	andi	s5,t4,7
    69ea:	9402                	jalr	s0
    69ec:	01ac85b3          	add	a1,s9,s10
    69f0:	7882                	ld	a7,32(sp)
    69f2:	1575f563          	bgeu	a1,s7,6b3c <_vsnprintf+0x422c>
    69f6:	0a0a8963          	beqz	s5,6aa8 <_vsnprintf+0x4198>
    69fa:	4685                	li	a3,1
    69fc:	08da8863          	beq	s5,a3,6a8c <_vsnprintf+0x417c>
    6a00:	4f89                	li	t6,2
    6a02:	07fa8c63          	beq	s5,t6,6a7a <_vsnprintf+0x416a>
    6a06:	480d                	li	a6,3
    6a08:	070a8063          	beq	s5,a6,6a68 <_vsnprintf+0x4158>
    6a0c:	4711                	li	a4,4
    6a0e:	04ea8463          	beq	s5,a4,6a56 <_vsnprintf+0x4146>
    6a12:	4f15                	li	t5,5
    6a14:	03ea8863          	beq	s5,t5,6a44 <_vsnprintf+0x4134>
    6a18:	4299                	li	t0,6
    6a1a:	005a8c63          	beq	s5,t0,6a32 <_vsnprintf+0x4122>
    6a1e:	866a                	mv	a2,s10
    6a20:	f046                	sd	a7,32(sp)
    6a22:	86a6                	mv	a3,s1
    6a24:	85ca                	mv	a1,s2
    6a26:	02000513          	li	a0,32
    6a2a:	6d02                	ld	s10,0(sp)
    6a2c:	9402                	jalr	s0
    6a2e:	7882                	ld	a7,32(sp)
    6a30:	0d09                	addi	s10,s10,2
    6a32:	866a                	mv	a2,s10
    6a34:	f046                	sd	a7,32(sp)
    6a36:	86a6                	mv	a3,s1
    6a38:	85ca                	mv	a1,s2
    6a3a:	02000513          	li	a0,32
    6a3e:	9402                	jalr	s0
    6a40:	7882                	ld	a7,32(sp)
    6a42:	0d05                	addi	s10,s10,1
    6a44:	866a                	mv	a2,s10
    6a46:	f046                	sd	a7,32(sp)
    6a48:	86a6                	mv	a3,s1
    6a4a:	85ca                	mv	a1,s2
    6a4c:	02000513          	li	a0,32
    6a50:	9402                	jalr	s0
    6a52:	7882                	ld	a7,32(sp)
    6a54:	0d05                	addi	s10,s10,1
    6a56:	866a                	mv	a2,s10
    6a58:	f046                	sd	a7,32(sp)
    6a5a:	86a6                	mv	a3,s1
    6a5c:	85ca                	mv	a1,s2
    6a5e:	02000513          	li	a0,32
    6a62:	9402                	jalr	s0
    6a64:	7882                	ld	a7,32(sp)
    6a66:	0d05                	addi	s10,s10,1
    6a68:	866a                	mv	a2,s10
    6a6a:	f046                	sd	a7,32(sp)
    6a6c:	86a6                	mv	a3,s1
    6a6e:	85ca                	mv	a1,s2
    6a70:	02000513          	li	a0,32
    6a74:	9402                	jalr	s0
    6a76:	7882                	ld	a7,32(sp)
    6a78:	0d05                	addi	s10,s10,1
    6a7a:	866a                	mv	a2,s10
    6a7c:	f046                	sd	a7,32(sp)
    6a7e:	86a6                	mv	a3,s1
    6a80:	85ca                	mv	a1,s2
    6a82:	02000513          	li	a0,32
    6a86:	9402                	jalr	s0
    6a88:	7882                	ld	a7,32(sp)
    6a8a:	0d05                	addi	s10,s10,1
    6a8c:	866a                	mv	a2,s10
    6a8e:	02000513          	li	a0,32
    6a92:	f046                	sd	a7,32(sp)
    6a94:	86a6                	mv	a3,s1
    6a96:	85ca                	mv	a1,s2
    6a98:	9402                	jalr	s0
    6a9a:	6362                	ld	t1,24(sp)
    6a9c:	7882                	ld	a7,32(sp)
    6a9e:	0d05                	addi	s10,s10,1
    6aa0:	01a30533          	add	a0,t1,s10
    6aa4:	09757c63          	bgeu	a0,s7,6b3c <_vsnprintf+0x422c>
    6aa8:	f06e                	sd	s11,32(sp)
    6aaa:	8dda                	mv	s11,s6
    6aac:	8b46                	mv	s6,a7
    6aae:	866a                	mv	a2,s10
    6ab0:	86a6                	mv	a3,s1
    6ab2:	85ca                	mv	a1,s2
    6ab4:	02000513          	li	a0,32
    6ab8:	9402                	jalr	s0
    6aba:	001d0a93          	addi	s5,s10,1
    6abe:	8656                	mv	a2,s5
    6ac0:	86a6                	mv	a3,s1
    6ac2:	85ca                	mv	a1,s2
    6ac4:	02000513          	li	a0,32
    6ac8:	9402                	jalr	s0
    6aca:	002d0c93          	addi	s9,s10,2
    6ace:	8666                	mv	a2,s9
    6ad0:	86a6                	mv	a3,s1
    6ad2:	85ca                	mv	a1,s2
    6ad4:	02000513          	li	a0,32
    6ad8:	9402                	jalr	s0
    6ada:	003d0a93          	addi	s5,s10,3
    6ade:	8656                	mv	a2,s5
    6ae0:	86a6                	mv	a3,s1
    6ae2:	85ca                	mv	a1,s2
    6ae4:	02000513          	li	a0,32
    6ae8:	9402                	jalr	s0
    6aea:	004d0c93          	addi	s9,s10,4
    6aee:	8666                	mv	a2,s9
    6af0:	86a6                	mv	a3,s1
    6af2:	85ca                	mv	a1,s2
    6af4:	02000513          	li	a0,32
    6af8:	9402                	jalr	s0
    6afa:	005d0a93          	addi	s5,s10,5
    6afe:	8656                	mv	a2,s5
    6b00:	86a6                	mv	a3,s1
    6b02:	85ca                	mv	a1,s2
    6b04:	02000513          	li	a0,32
    6b08:	9402                	jalr	s0
    6b0a:	006d0c93          	addi	s9,s10,6
    6b0e:	86a6                	mv	a3,s1
    6b10:	8666                	mv	a2,s9
    6b12:	85ca                	mv	a1,s2
    6b14:	02000513          	li	a0,32
    6b18:	9402                	jalr	s0
    6b1a:	007d0a93          	addi	s5,s10,7
    6b1e:	86a6                	mv	a3,s1
    6b20:	8656                	mv	a2,s5
    6b22:	85ca                	mv	a1,s2
    6b24:	02000513          	li	a0,32
    6b28:	9402                	jalr	s0
    6b2a:	68e2                	ld	a7,24(sp)
    6b2c:	0d21                	addi	s10,s10,8
    6b2e:	01a88e33          	add	t3,a7,s10
    6b32:	f77e6ee3          	bltu	t3,s7,6aae <_vsnprintf+0x419e>
    6b36:	88da                	mv	a7,s6
    6b38:	8b6e                	mv	s6,s11
    6b3a:	7d82                	ld	s11,32(sp)
    6b3c:	6682                	ld	a3,0(sp)
    6b3e:	fffb8613          	addi	a2,s7,-1
    6b42:	001c0793          	addi	a5,s8,1
    6b46:	418603b3          	sub	t2,a2,s8
    6b4a:	00fbbeb3          	sltu	t4,s7,a5
    6b4e:	43d0138b          	th.mvnez	t2,zero,t4
    6b52:	00168f93          	addi	t6,a3,1
    6b56:	01f38833          	add	a6,t2,t6
    6b5a:	8e42                	mv	t3,a6
    6b5c:	da0c0863          	beqz	s8,610c <_vsnprintf+0x37fc>
    6b60:	03010c93          	addi	s9,sp,48
    6b64:	019c0733          	add	a4,s8,s9
    6b68:	fff74503          	lbu	a0,-1(a4)
    6b6c:	c3eff06f          	j	5faa <_vsnprintf+0x369a>
    6b70:	54088fe3          	beqz	a7,78ce <_vsnprintf+0x4fbe>
    6b74:	00167b13          	andi	s6,a2,1
    6b78:	7c0c350b          	th.extu	a0,s8,31,0
    6b7c:	000b1463          	bnez	s6,6b84 <_vsnprintf+0x4274>
    6b80:	0e80106f          	j	7c68 <_vsnprintf+0x5358>
    6b84:	0ea77763          	bgeu	a4,a0,6c72 <_vsnprintf+0x4362>
    6b88:	02000593          	li	a1,32
    6b8c:	40e582b3          	sub	t0,a1,a4
    6b90:	0072f393          	andi	t2,t0,7
    6b94:	00e80f33          	add	t5,a6,a4
    6b98:	03000f93          	li	t6,48
    6b9c:	06038763          	beqz	t2,6c0a <_vsnprintf+0x42fa>
    6ba0:	0705                	addi	a4,a4,1
    6ba2:	181f5f8b          	th.sbia	t6,(t5),1,0
    6ba6:	0ca77463          	bgeu	a4,a0,6c6e <_vsnprintf+0x435e>
    6baa:	4a85                	li	s5,1
    6bac:	05538f63          	beq	t2,s5,6c0a <_vsnprintf+0x42fa>
    6bb0:	4309                	li	t1,2
    6bb2:	04638763          	beq	t2,t1,6c00 <_vsnprintf+0x42f0>
    6bb6:	478d                	li	a5,3
    6bb8:	02f38f63          	beq	t2,a5,6bf6 <_vsnprintf+0x42e6>
    6bbc:	4611                	li	a2,4
    6bbe:	02c38763          	beq	t2,a2,6bec <_vsnprintf+0x42dc>
    6bc2:	4c95                	li	s9,5
    6bc4:	01938f63          	beq	t2,s9,6be2 <_vsnprintf+0x42d2>
    6bc8:	4299                	li	t0,6
    6bca:	00538763          	beq	t2,t0,6bd8 <_vsnprintf+0x42c8>
    6bce:	0705                	addi	a4,a4,1
    6bd0:	181f5f8b          	th.sbia	t6,(t5),1,0
    6bd4:	08a77d63          	bgeu	a4,a0,6c6e <_vsnprintf+0x435e>
    6bd8:	0705                	addi	a4,a4,1
    6bda:	181f5f8b          	th.sbia	t6,(t5),1,0
    6bde:	08a77863          	bgeu	a4,a0,6c6e <_vsnprintf+0x435e>
    6be2:	0705                	addi	a4,a4,1
    6be4:	181f5f8b          	th.sbia	t6,(t5),1,0
    6be8:	08a77363          	bgeu	a4,a0,6c6e <_vsnprintf+0x435e>
    6bec:	0705                	addi	a4,a4,1
    6bee:	181f5f8b          	th.sbia	t6,(t5),1,0
    6bf2:	06a77e63          	bgeu	a4,a0,6c6e <_vsnprintf+0x435e>
    6bf6:	0705                	addi	a4,a4,1
    6bf8:	181f5f8b          	th.sbia	t6,(t5),1,0
    6bfc:	06a77963          	bgeu	a4,a0,6c6e <_vsnprintf+0x435e>
    6c00:	0705                	addi	a4,a4,1
    6c02:	181f5f8b          	th.sbia	t6,(t5),1,0
    6c06:	06a77463          	bgeu	a4,a0,6c6e <_vsnprintf+0x435e>
    6c0a:	06b70263          	beq	a4,a1,6c6e <_vsnprintf+0x435e>
    6c0e:	0705                	addi	a4,a4,1
    6c10:	01ff0023          	sb	t6,0(t5)
    6c14:	83ba                	mv	t2,a4
    6c16:	04a77c63          	bgeu	a4,a0,6c6e <_vsnprintf+0x435e>
    6c1a:	0705                	addi	a4,a4,1
    6c1c:	01ff00a3          	sb	t6,1(t5)
    6c20:	04a77763          	bgeu	a4,a0,6c6e <_vsnprintf+0x435e>
    6c24:	00238713          	addi	a4,t2,2
    6c28:	01ff0123          	sb	t6,2(t5)
    6c2c:	04a77163          	bgeu	a4,a0,6c6e <_vsnprintf+0x435e>
    6c30:	00338713          	addi	a4,t2,3
    6c34:	01ff01a3          	sb	t6,3(t5)
    6c38:	02a77b63          	bgeu	a4,a0,6c6e <_vsnprintf+0x435e>
    6c3c:	00438713          	addi	a4,t2,4
    6c40:	01ff0223          	sb	t6,4(t5)
    6c44:	02a77563          	bgeu	a4,a0,6c6e <_vsnprintf+0x435e>
    6c48:	00538713          	addi	a4,t2,5
    6c4c:	01ff02a3          	sb	t6,5(t5)
    6c50:	00a77f63          	bgeu	a4,a0,6c6e <_vsnprintf+0x435e>
    6c54:	00638713          	addi	a4,t2,6
    6c58:	01ff0323          	sb	t6,6(t5)
    6c5c:	00a77963          	bgeu	a4,a0,6c6e <_vsnprintf+0x435e>
    6c60:	01ff03a3          	sb	t6,7(t5)
    6c64:	00738713          	addi	a4,t2,7
    6c68:	0f21                	addi	t5,t5,8
    6c6a:	faa760e3          	bltu	a4,a0,6c0a <_vsnprintf+0x42fa>
    6c6e:	5a0b07e3          	beqz	s6,7a1c <_vsnprintf+0x510c>
    6c72:	7c08b78b          	th.extu	a5,a7,31,0
    6c76:	00f76463          	bltu	a4,a5,6c7e <_vsnprintf+0x436e>
    6c7a:	6e70106f          	j	8b60 <_vsnprintf+0x6250>
    6c7e:	02000b13          	li	s6,32
    6c82:	40eb0fb3          	sub	t6,s6,a4
    6c86:	007ffa93          	andi	s5,t6,7
    6c8a:	00e805b3          	add	a1,a6,a4
    6c8e:	03000513          	li	a0,48
    6c92:	060a8763          	beqz	s5,6d00 <_vsnprintf+0x43f0>
    6c96:	0705                	addi	a4,a4,1
    6c98:	1815d50b          	th.sbia	a0,(a1),1,0
    6c9c:	0ce78463          	beq	a5,a4,6d64 <_vsnprintf+0x4454>
    6ca0:	4305                	li	t1,1
    6ca2:	046a8f63          	beq	s5,t1,6d00 <_vsnprintf+0x43f0>
    6ca6:	4609                	li	a2,2
    6ca8:	04ca8763          	beq	s5,a2,6cf6 <_vsnprintf+0x43e6>
    6cac:	4c8d                	li	s9,3
    6cae:	039a8f63          	beq	s5,s9,6cec <_vsnprintf+0x43dc>
    6cb2:	4291                	li	t0,4
    6cb4:	025a8763          	beq	s5,t0,6ce2 <_vsnprintf+0x43d2>
    6cb8:	4395                	li	t2,5
    6cba:	007a8f63          	beq	s5,t2,6cd8 <_vsnprintf+0x43c8>
    6cbe:	4f19                	li	t5,6
    6cc0:	01ea8763          	beq	s5,t5,6cce <_vsnprintf+0x43be>
    6cc4:	0705                	addi	a4,a4,1
    6cc6:	1815d50b          	th.sbia	a0,(a1),1,0
    6cca:	08e78d63          	beq	a5,a4,6d64 <_vsnprintf+0x4454>
    6cce:	0705                	addi	a4,a4,1
    6cd0:	1815d50b          	th.sbia	a0,(a1),1,0
    6cd4:	08e78863          	beq	a5,a4,6d64 <_vsnprintf+0x4454>
    6cd8:	0705                	addi	a4,a4,1
    6cda:	1815d50b          	th.sbia	a0,(a1),1,0
    6cde:	08e78363          	beq	a5,a4,6d64 <_vsnprintf+0x4454>
    6ce2:	0705                	addi	a4,a4,1
    6ce4:	1815d50b          	th.sbia	a0,(a1),1,0
    6ce8:	06e78e63          	beq	a5,a4,6d64 <_vsnprintf+0x4454>
    6cec:	0705                	addi	a4,a4,1
    6cee:	1815d50b          	th.sbia	a0,(a1),1,0
    6cf2:	06e78963          	beq	a5,a4,6d64 <_vsnprintf+0x4454>
    6cf6:	0705                	addi	a4,a4,1
    6cf8:	1815d50b          	th.sbia	a0,(a1),1,0
    6cfc:	06e78463          	beq	a5,a4,6d64 <_vsnprintf+0x4454>
    6d00:	47670ae3          	beq	a4,s6,7974 <_vsnprintf+0x5064>
    6d04:	0705                	addi	a4,a4,1
    6d06:	00a58023          	sb	a0,0(a1)
    6d0a:	8fba                	mv	t6,a4
    6d0c:	04e78c63          	beq	a5,a4,6d64 <_vsnprintf+0x4454>
    6d10:	0705                	addi	a4,a4,1
    6d12:	00a580a3          	sb	a0,1(a1)
    6d16:	04e78763          	beq	a5,a4,6d64 <_vsnprintf+0x4454>
    6d1a:	002f8713          	addi	a4,t6,2
    6d1e:	00a58123          	sb	a0,2(a1)
    6d22:	04e78163          	beq	a5,a4,6d64 <_vsnprintf+0x4454>
    6d26:	003f8713          	addi	a4,t6,3
    6d2a:	00a581a3          	sb	a0,3(a1)
    6d2e:	02e78b63          	beq	a5,a4,6d64 <_vsnprintf+0x4454>
    6d32:	004f8713          	addi	a4,t6,4
    6d36:	00a58223          	sb	a0,4(a1)
    6d3a:	02e78563          	beq	a5,a4,6d64 <_vsnprintf+0x4454>
    6d3e:	005f8713          	addi	a4,t6,5
    6d42:	00a582a3          	sb	a0,5(a1)
    6d46:	00e78f63          	beq	a5,a4,6d64 <_vsnprintf+0x4454>
    6d4a:	006f8713          	addi	a4,t6,6
    6d4e:	00a58323          	sb	a0,6(a1)
    6d52:	00e78963          	beq	a5,a4,6d64 <_vsnprintf+0x4454>
    6d56:	00a583a3          	sb	a0,7(a1)
    6d5a:	007f8713          	addi	a4,t6,7
    6d5e:	05a1                	addi	a1,a1,8
    6d60:	fae790e3          	bne	a5,a4,6d00 <_vsnprintf+0x43f0>
    6d64:	140e99e3          	bnez	t4,76b6 <_vsnprintf+0x4da6>
    6d68:	01671463          	bne	a4,s6,6d70 <_vsnprintf+0x4460>
    6d6c:	e4cfe06f          	j	53b8 <_vsnprintf+0x2aa8>
    6d70:	003e7d13          	andi	s10,t3,3
    6d74:	000d0463          	beqz	s10,6d7c <_vsnprintf+0x446c>
    6d78:	7a10106f          	j	8d18 <_vsnprintf+0x6408>
    6d7c:	8c3e                	mv	s8,a5
    6d7e:	16f765e3          	bltu	a4,a5,76e8 <_vsnprintf+0x4dd8>
    6d82:	6e02                	ld	t3,0(sp)
    6d84:	e3afe06f          	j	53be <_vsnprintf+0x2aae>
    6d88:	47c1                	li	a5,16
    6d8a:	8abe                	mv	s5,a5
    6d8c:	01f8f463          	bgeu	a7,t6,6d94 <_vsnprintf+0x4484>
    6d90:	f0ffd06f          	j	4c9e <_vsnprintf+0x238e>
    6d94:	000b9463          	bnez	s7,6d9c <_vsnprintf+0x448c>
    6d98:	c10fe06f          	j	51a8 <_vsnprintf+0x2898>
    6d9c:	4b81                	li	s7,0
    6d9e:	8a0c9ae3          	bnez	s9,6652 <_vsnprintf+0x3d42>
    6da2:	01fd1463          	bne	s10,t6,6daa <_vsnprintf+0x449a>
    6da6:	3ec0106f          	j	8192 <_vsnprintf+0x5882>
    6daa:	8ba794e3          	bne	a5,s10,6652 <_vsnprintf+0x3d42>
    6dae:	3ed0006f          	j	799a <_vsnprintf+0x508a>
    6db2:	0001                	nop
    6db4:	ec46                	sd	a7,24(sp)
    6db6:	f056                	sd	s5,32(sp)
    6db8:	6b82                	ld	s7,0(sp)
    6dba:	8cbe                	mv	s9,a5
    6dbc:	a5dfe06f          	j	5818 <_vsnprintf+0x2f08>
    6dc0:	000f9463          	bnez	t6,6dc8 <_vsnprintf+0x44b8>
    6dc4:	77d0106f          	j	8d40 <_vsnprintf+0x6430>
    6dc8:	47c1                	li	a5,16
    6dca:	4d01                	li	s10,0
    6dcc:	40000c93          	li	s9,1024
    6dd0:	8abe                	mv	s5,a5
    6dd2:	03010b13          	addi	s6,sp,48
    6dd6:	ec9fd06f          	j	4c9e <_vsnprintf+0x238e>
    6dda:	588dce0b          	th.lwia	t3,(s11),8,0
    6dde:	41fe551b          	sraiw	a0,t3,0x1f
    6de2:	00ae4633          	xor	a2,t3,a0
    6de6:	40a603bb          	subw	t2,a2,a0
    6dea:	a3ffd06f          	j	4828 <_vsnprintf+0x1f18>
    6dee:	00857713          	andi	a4,a0,8
    6df2:	40071fe3          	bnez	a4,7a10 <_vsnprintf+0x5100>
    6df6:	6a82                	ld	s5,0(sp)
    6df8:	4d01                	li	s10,0
    6dfa:	4bc1                	li	s7,16
    6dfc:	96dfd06f          	j	4768 <_vsnprintf+0x1e58>
    6e00:	05800f13          	li	t5,88
    6e04:	05e10023          	sb	t5,64(sp)
    6e08:	4b81                	li	s7,0
    6e0a:	47c5                	li	a5,17
    6e0c:	b8cfe06f          	j	5198 <_vsnprintf+0x2888>
    6e10:	0025fb93          	andi	s7,a1,2
    6e14:	8d2e                	mv	s10,a1
    6e16:	300b97e3          	bnez	s7,7924 <_vsnprintf+0x5014>
    6e1a:	00089463          	bnez	a7,6e22 <_vsnprintf+0x4512>
    6e1e:	0b40106f          	j	7ed2 <_vsnprintf+0x55c2>
    6e22:	001d7f93          	andi	t6,s10,1
    6e26:	000f8463          	beqz	t6,6e2e <_vsnprintf+0x451e>
    6e2a:	4e20106f          	j	830c <_vsnprintf+0x59fc>
    6e2e:	7c0c3c0b          	th.extu	s8,s8,31,0
    6e32:	4781                	li	a5,0
    6e34:	03010b93          	addi	s7,sp,48
    6e38:	c60c1763          	bnez	s8,62a6 <_vsnprintf+0x3996>
    6e3c:	004d7b13          	andi	s6,s10,4
    6e40:	000b1463          	bnez	s6,6e48 <_vsnprintf+0x4538>
    6e44:	6cb0106f          	j	8d0e <_vsnprintf+0x63fe>
    6e48:	02b00693          	li	a3,43
    6e4c:	02d10823          	sb	a3,48(sp)
    6e50:	4c05                	li	s8,1
    6e52:	7c08bd0b          	th.extu	s10,a7,31,0
    6e56:	4b01                	li	s6,0
    6e58:	01ac6463          	bltu	s8,s10,6e60 <_vsnprintf+0x4550>
    6e5c:	6a50106f          	j	8d00 <_vsnprintf+0x63f0>
    6e60:	6602                	ld	a2,0(sp)
    6e62:	02000513          	li	a0,32
    6e66:	86a6                	mv	a3,s1
    6e68:	40cc0cb3          	sub	s9,s8,a2
    6e6c:	fffcc713          	not	a4,s9
    6e70:	40c70fb3          	sub	t6,a4,a2
    6e74:	01af8bb3          	add	s7,t6,s10
    6e78:	ec66                	sd	s9,24(sp)
    6e7a:	f046                	sd	a7,32(sp)
    6e7c:	85ca                	mv	a1,s2
    6e7e:	007bfa93          	andi	s5,s7,7
    6e82:	00160b93          	addi	s7,a2,1
    6e86:	9402                	jalr	s0
    6e88:	017c8533          	add	a0,s9,s7
    6e8c:	7882                	ld	a7,32(sp)
    6e8e:	15a57663          	bgeu	a0,s10,6fda <_vsnprintf+0x46ca>
    6e92:	0a0a8a63          	beqz	s5,6f46 <_vsnprintf+0x4636>
    6e96:	4685                	li	a3,1
    6e98:	08da8963          	beq	s5,a3,6f2a <_vsnprintf+0x461a>
    6e9c:	4789                	li	a5,2
    6e9e:	06fa8d63          	beq	s5,a5,6f18 <_vsnprintf+0x4608>
    6ea2:	428d                	li	t0,3
    6ea4:	065a8163          	beq	s5,t0,6f06 <_vsnprintf+0x45f6>
    6ea8:	4591                	li	a1,4
    6eaa:	04ba8563          	beq	s5,a1,6ef4 <_vsnprintf+0x45e4>
    6eae:	4395                	li	t2,5
    6eb0:	027a8963          	beq	s5,t2,6ee2 <_vsnprintf+0x45d2>
    6eb4:	4f19                	li	t5,6
    6eb6:	01ea8d63          	beq	s5,t5,6ed0 <_vsnprintf+0x45c0>
    6eba:	6302                	ld	t1,0(sp)
    6ebc:	865e                	mv	a2,s7
    6ebe:	f046                	sd	a7,32(sp)
    6ec0:	86a6                	mv	a3,s1
    6ec2:	85ca                	mv	a1,s2
    6ec4:	02000513          	li	a0,32
    6ec8:	00230b93          	addi	s7,t1,2
    6ecc:	9402                	jalr	s0
    6ece:	7882                	ld	a7,32(sp)
    6ed0:	865e                	mv	a2,s7
    6ed2:	f046                	sd	a7,32(sp)
    6ed4:	86a6                	mv	a3,s1
    6ed6:	85ca                	mv	a1,s2
    6ed8:	02000513          	li	a0,32
    6edc:	9402                	jalr	s0
    6ede:	7882                	ld	a7,32(sp)
    6ee0:	0b85                	addi	s7,s7,1
    6ee2:	865e                	mv	a2,s7
    6ee4:	f046                	sd	a7,32(sp)
    6ee6:	86a6                	mv	a3,s1
    6ee8:	85ca                	mv	a1,s2
    6eea:	02000513          	li	a0,32
    6eee:	9402                	jalr	s0
    6ef0:	7882                	ld	a7,32(sp)
    6ef2:	0b85                	addi	s7,s7,1
    6ef4:	865e                	mv	a2,s7
    6ef6:	f046                	sd	a7,32(sp)
    6ef8:	86a6                	mv	a3,s1
    6efa:	85ca                	mv	a1,s2
    6efc:	02000513          	li	a0,32
    6f00:	9402                	jalr	s0
    6f02:	7882                	ld	a7,32(sp)
    6f04:	0b85                	addi	s7,s7,1
    6f06:	865e                	mv	a2,s7
    6f08:	f046                	sd	a7,32(sp)
    6f0a:	86a6                	mv	a3,s1
    6f0c:	85ca                	mv	a1,s2
    6f0e:	02000513          	li	a0,32
    6f12:	9402                	jalr	s0
    6f14:	7882                	ld	a7,32(sp)
    6f16:	0b85                	addi	s7,s7,1
    6f18:	865e                	mv	a2,s7
    6f1a:	f046                	sd	a7,32(sp)
    6f1c:	86a6                	mv	a3,s1
    6f1e:	85ca                	mv	a1,s2
    6f20:	02000513          	li	a0,32
    6f24:	9402                	jalr	s0
    6f26:	7882                	ld	a7,32(sp)
    6f28:	0b85                	addi	s7,s7,1
    6f2a:	865e                	mv	a2,s7
    6f2c:	f046                	sd	a7,32(sp)
    6f2e:	86a6                	mv	a3,s1
    6f30:	85ca                	mv	a1,s2
    6f32:	02000513          	li	a0,32
    6f36:	9402                	jalr	s0
    6f38:	6862                	ld	a6,24(sp)
    6f3a:	7882                	ld	a7,32(sp)
    6f3c:	0b85                	addi	s7,s7,1
    6f3e:	01780eb3          	add	t4,a6,s7
    6f42:	09aefc63          	bgeu	t4,s10,6fda <_vsnprintf+0x46ca>
    6f46:	f06e                	sd	s11,32(sp)
    6f48:	8dda                	mv	s11,s6
    6f4a:	8b46                	mv	s6,a7
    6f4c:	865e                	mv	a2,s7
    6f4e:	86a6                	mv	a3,s1
    6f50:	85ca                	mv	a1,s2
    6f52:	02000513          	li	a0,32
    6f56:	9402                	jalr	s0
    6f58:	001b8a93          	addi	s5,s7,1
    6f5c:	8656                	mv	a2,s5
    6f5e:	86a6                	mv	a3,s1
    6f60:	85ca                	mv	a1,s2
    6f62:	02000513          	li	a0,32
    6f66:	9402                	jalr	s0
    6f68:	002b8c93          	addi	s9,s7,2
    6f6c:	8666                	mv	a2,s9
    6f6e:	86a6                	mv	a3,s1
    6f70:	85ca                	mv	a1,s2
    6f72:	02000513          	li	a0,32
    6f76:	9402                	jalr	s0
    6f78:	003b8a93          	addi	s5,s7,3
    6f7c:	8656                	mv	a2,s5
    6f7e:	86a6                	mv	a3,s1
    6f80:	85ca                	mv	a1,s2
    6f82:	02000513          	li	a0,32
    6f86:	9402                	jalr	s0
    6f88:	004b8c93          	addi	s9,s7,4
    6f8c:	8666                	mv	a2,s9
    6f8e:	86a6                	mv	a3,s1
    6f90:	85ca                	mv	a1,s2
    6f92:	02000513          	li	a0,32
    6f96:	9402                	jalr	s0
    6f98:	005b8a93          	addi	s5,s7,5
    6f9c:	8656                	mv	a2,s5
    6f9e:	86a6                	mv	a3,s1
    6fa0:	85ca                	mv	a1,s2
    6fa2:	02000513          	li	a0,32
    6fa6:	9402                	jalr	s0
    6fa8:	006b8c93          	addi	s9,s7,6
    6fac:	86a6                	mv	a3,s1
    6fae:	8666                	mv	a2,s9
    6fb0:	85ca                	mv	a1,s2
    6fb2:	02000513          	li	a0,32
    6fb6:	9402                	jalr	s0
    6fb8:	007b8a93          	addi	s5,s7,7
    6fbc:	86a6                	mv	a3,s1
    6fbe:	8656                	mv	a2,s5
    6fc0:	85ca                	mv	a1,s2
    6fc2:	02000513          	li	a0,32
    6fc6:	9402                	jalr	s0
    6fc8:	68e2                	ld	a7,24(sp)
    6fca:	0ba1                	addi	s7,s7,8
    6fcc:	01788e33          	add	t3,a7,s7
    6fd0:	f7ae6ee3          	bltu	t3,s10,6f4c <_vsnprintf+0x463c>
    6fd4:	88da                	mv	a7,s6
    6fd6:	8b6e                	mv	s6,s11
    6fd8:	7d82                	ld	s11,32(sp)
    6fda:	6682                	ld	a3,0(sp)
    6fdc:	fffd0613          	addi	a2,s10,-1
    6fe0:	001c0713          	addi	a4,s8,1
    6fe4:	41860fb3          	sub	t6,a2,s8
    6fe8:	00ed3533          	sltu	a0,s10,a4
    6fec:	42a01f8b          	th.mvnez	t6,zero,a0
    6ff0:	00168793          	addi	a5,a3,1
    6ff4:	00ff8333          	add	t1,t6,a5
    6ff8:	8a9a                	mv	s5,t1
    6ffa:	000c1463          	bnez	s8,7002 <_vsnprintf+0x46f2>
    6ffe:	afbfd06f          	j	4af8 <_vsnprintf+0x21e8>
    7002:	002c03b3          	add	t2,s8,sp
    7006:	02f3c503          	lbu	a0,47(t2)
    700a:	03010b93          	addi	s7,sp,48
    700e:	989fd06f          	j	4996 <_vsnprintf+0x2086>
    7012:	0035ff93          	andi	t6,a1,3
    7016:	020f9d63          	bnez	t6,7050 <_vsnprintf+0x4740>
    701a:	02000c13          	li	s8,32
    701e:	7c08bd0b          	th.extu	s10,a7,31,0
    7022:	4b01                	li	s6,0
    7024:	e31c6ee3          	bltu	s8,a7,6e60 <_vsnprintf+0x4550>
    7028:	04f14503          	lbu	a0,79(sp)
    702c:	6302                	ld	t1,0(sp)
    702e:	02000c13          	li	s8,32
    7032:	4b01                	li	s6,0
    7034:	963fd06f          	j	4996 <_vsnprintf+0x2086>
    7038:	ec46                	sd	a7,24(sp)
    703a:	f05a                	sd	s6,32(sp)
    703c:	aa5fd06f          	j	4ae0 <_vsnprintf+0x21d0>
    7040:	fc0f89e3          	beqz	t6,7012 <_vsnprintf+0x4702>
    7044:	7c08bf8b          	th.extu	t6,a7,31,0
    7048:	b5f7ea63          	bltu	a5,t6,639c <_vsnprintf+0x3a8c>
    704c:	898d                	andi	a1,a1,3
    704e:	dde9                	beqz	a1,7028 <_vsnprintf+0x4718>
    7050:	4b01                	li	s6,0
    7052:	93bfd06f          	j	498c <_vsnprintf+0x207c>
    7056:	7c0c3c0b          	th.extu	s8,s8,31,0
    705a:	0187e463          	bltu	a5,s8,7062 <_vsnprintf+0x4752>
    705e:	4170106f          	j	8c74 <_vsnprintf+0x6364>
    7062:	0015ff93          	andi	t6,a1,1
    7066:	4881                	li	a7,0
    7068:	a3eff06f          	j	62a6 <_vsnprintf+0x3996>
    706c:	0a0882e3          	beqz	a7,7910 <_vsnprintf+0x5000>
    7070:	0015fb13          	andi	s6,a1,1
    7074:	7c0c350b          	th.extu	a0,s8,31,0
    7078:	000b1463          	bnez	s6,7080 <_vsnprintf+0x4770>
    707c:	32c0106f          	j	83a8 <_vsnprintf+0x5a98>
    7080:	0eadf763          	bgeu	s11,a0,716e <_vsnprintf+0x485e>
    7084:	02000713          	li	a4,32
    7088:	41b70cb3          	sub	s9,a4,s11
    708c:	007cff13          	andi	t5,s9,7
    7090:	01b80e33          	add	t3,a6,s11
    7094:	03000293          	li	t0,48
    7098:	060f0763          	beqz	t5,7106 <_vsnprintf+0x47f6>
    709c:	0d85                	addi	s11,s11,1
    709e:	181e528b          	th.sbia	t0,(t3),1,0
    70a2:	0cadf463          	bgeu	s11,a0,716a <_vsnprintf+0x485a>
    70a6:	4f85                	li	t6,1
    70a8:	05ff0f63          	beq	t5,t6,7106 <_vsnprintf+0x47f6>
    70ac:	4789                	li	a5,2
    70ae:	04ff0763          	beq	t5,a5,70fc <_vsnprintf+0x47ec>
    70b2:	458d                	li	a1,3
    70b4:	02bf0f63          	beq	t5,a1,70f2 <_vsnprintf+0x47e2>
    70b8:	4391                	li	t2,4
    70ba:	027f0763          	beq	t5,t2,70e8 <_vsnprintf+0x47d8>
    70be:	4315                	li	t1,5
    70c0:	006f0f63          	beq	t5,t1,70de <_vsnprintf+0x47ce>
    70c4:	4e99                	li	t4,6
    70c6:	01df0763          	beq	t5,t4,70d4 <_vsnprintf+0x47c4>
    70ca:	0d85                	addi	s11,s11,1
    70cc:	181e528b          	th.sbia	t0,(t3),1,0
    70d0:	08adfd63          	bgeu	s11,a0,716a <_vsnprintf+0x485a>
    70d4:	0d85                	addi	s11,s11,1
    70d6:	181e528b          	th.sbia	t0,(t3),1,0
    70da:	08adf863          	bgeu	s11,a0,716a <_vsnprintf+0x485a>
    70de:	0d85                	addi	s11,s11,1
    70e0:	181e528b          	th.sbia	t0,(t3),1,0
    70e4:	08adf363          	bgeu	s11,a0,716a <_vsnprintf+0x485a>
    70e8:	0d85                	addi	s11,s11,1
    70ea:	181e528b          	th.sbia	t0,(t3),1,0
    70ee:	06adfe63          	bgeu	s11,a0,716a <_vsnprintf+0x485a>
    70f2:	0d85                	addi	s11,s11,1
    70f4:	181e528b          	th.sbia	t0,(t3),1,0
    70f8:	06adf963          	bgeu	s11,a0,716a <_vsnprintf+0x485a>
    70fc:	0d85                	addi	s11,s11,1
    70fe:	181e528b          	th.sbia	t0,(t3),1,0
    7102:	06adf463          	bgeu	s11,a0,716a <_vsnprintf+0x485a>
    7106:	06ed8263          	beq	s11,a4,716a <_vsnprintf+0x485a>
    710a:	0d85                	addi	s11,s11,1
    710c:	005e0023          	sb	t0,0(t3)
    7110:	8cee                	mv	s9,s11
    7112:	04adfc63          	bgeu	s11,a0,716a <_vsnprintf+0x485a>
    7116:	0d85                	addi	s11,s11,1
    7118:	005e00a3          	sb	t0,1(t3)
    711c:	04adf763          	bgeu	s11,a0,716a <_vsnprintf+0x485a>
    7120:	002c8d93          	addi	s11,s9,2
    7124:	005e0123          	sb	t0,2(t3)
    7128:	04adf163          	bgeu	s11,a0,716a <_vsnprintf+0x485a>
    712c:	003c8d93          	addi	s11,s9,3
    7130:	005e01a3          	sb	t0,3(t3)
    7134:	02adfb63          	bgeu	s11,a0,716a <_vsnprintf+0x485a>
    7138:	004c8d93          	addi	s11,s9,4
    713c:	005e0223          	sb	t0,4(t3)
    7140:	02adf563          	bgeu	s11,a0,716a <_vsnprintf+0x485a>
    7144:	005c8d93          	addi	s11,s9,5
    7148:	005e02a3          	sb	t0,5(t3)
    714c:	00adff63          	bgeu	s11,a0,716a <_vsnprintf+0x485a>
    7150:	006c8d93          	addi	s11,s9,6
    7154:	005e0323          	sb	t0,6(t3)
    7158:	00adf963          	bgeu	s11,a0,716a <_vsnprintf+0x485a>
    715c:	005e03a3          	sb	t0,7(t3)
    7160:	007c8d93          	addi	s11,s9,7
    7164:	0e21                	addi	t3,t3,8
    7166:	faade0e3          	bltu	s11,a0,7106 <_vsnprintf+0x47f6>
    716a:	3e0b09e3          	beqz	s6,7d5c <_vsnprintf+0x544c>
    716e:	7c08b50b          	th.extu	a0,a7,31,0
    7172:	4aadf4e3          	bgeu	s11,a0,7e1a <_vsnprintf+0x550a>
    7176:	02000b13          	li	s6,32
    717a:	41bb02b3          	sub	t0,s6,s11
    717e:	0072ff93          	andi	t6,t0,7
    7182:	01b805b3          	add	a1,a6,s11
    7186:	03000713          	li	a4,48
    718a:	060f8763          	beqz	t6,71f8 <_vsnprintf+0x48e8>
    718e:	0d85                	addi	s11,s11,1
    7190:	1815d70b          	th.sbia	a4,(a1),1,0
    7194:	0db50463          	beq	a0,s11,725c <_vsnprintf+0x494c>
    7198:	4f05                	li	t5,1
    719a:	05ef8f63          	beq	t6,t5,71f8 <_vsnprintf+0x48e8>
    719e:	4789                	li	a5,2
    71a0:	04ff8763          	beq	t6,a5,71ee <_vsnprintf+0x48de>
    71a4:	438d                	li	t2,3
    71a6:	027f8f63          	beq	t6,t2,71e4 <_vsnprintf+0x48d4>
    71aa:	4311                	li	t1,4
    71ac:	026f8763          	beq	t6,t1,71da <_vsnprintf+0x48ca>
    71b0:	4e95                	li	t4,5
    71b2:	01df8f63          	beq	t6,t4,71d0 <_vsnprintf+0x48c0>
    71b6:	4c99                	li	s9,6
    71b8:	019f8763          	beq	t6,s9,71c6 <_vsnprintf+0x48b6>
    71bc:	0d85                	addi	s11,s11,1
    71be:	1815d70b          	th.sbia	a4,(a1),1,0
    71c2:	09b50d63          	beq	a0,s11,725c <_vsnprintf+0x494c>
    71c6:	0d85                	addi	s11,s11,1
    71c8:	1815d70b          	th.sbia	a4,(a1),1,0
    71cc:	09b50863          	beq	a0,s11,725c <_vsnprintf+0x494c>
    71d0:	0d85                	addi	s11,s11,1
    71d2:	1815d70b          	th.sbia	a4,(a1),1,0
    71d6:	09b50363          	beq	a0,s11,725c <_vsnprintf+0x494c>
    71da:	0d85                	addi	s11,s11,1
    71dc:	1815d70b          	th.sbia	a4,(a1),1,0
    71e0:	07b50e63          	beq	a0,s11,725c <_vsnprintf+0x494c>
    71e4:	0d85                	addi	s11,s11,1
    71e6:	1815d70b          	th.sbia	a4,(a1),1,0
    71ea:	07b50963          	beq	a0,s11,725c <_vsnprintf+0x494c>
    71ee:	0d85                	addi	s11,s11,1
    71f0:	1815d70b          	th.sbia	a4,(a1),1,0
    71f4:	07b50463          	beq	a0,s11,725c <_vsnprintf+0x494c>
    71f8:	2f6d8ae3          	beq	s11,s6,7cec <_vsnprintf+0x53dc>
    71fc:	0d85                	addi	s11,s11,1
    71fe:	00e58023          	sb	a4,0(a1)
    7202:	82ee                	mv	t0,s11
    7204:	05b50c63          	beq	a0,s11,725c <_vsnprintf+0x494c>
    7208:	0d85                	addi	s11,s11,1
    720a:	00e580a3          	sb	a4,1(a1)
    720e:	05b50763          	beq	a0,s11,725c <_vsnprintf+0x494c>
    7212:	00228d93          	addi	s11,t0,2
    7216:	00e58123          	sb	a4,2(a1)
    721a:	05b50163          	beq	a0,s11,725c <_vsnprintf+0x494c>
    721e:	00328d93          	addi	s11,t0,3
    7222:	00e581a3          	sb	a4,3(a1)
    7226:	03b50b63          	beq	a0,s11,725c <_vsnprintf+0x494c>
    722a:	00428d93          	addi	s11,t0,4
    722e:	00e58223          	sb	a4,4(a1)
    7232:	03b50563          	beq	a0,s11,725c <_vsnprintf+0x494c>
    7236:	00528d93          	addi	s11,t0,5
    723a:	00e582a3          	sb	a4,5(a1)
    723e:	01b50f63          	beq	a0,s11,725c <_vsnprintf+0x494c>
    7242:	00628d93          	addi	s11,t0,6
    7246:	00e58323          	sb	a4,6(a1)
    724a:	01b50963          	beq	a0,s11,725c <_vsnprintf+0x494c>
    724e:	00e583a3          	sb	a4,7(a1)
    7252:	00728d93          	addi	s11,t0,7
    7256:	05a1                	addi	a1,a1,8
    7258:	fbb510e3          	bne	a0,s11,71f8 <_vsnprintf+0x48e8>
    725c:	000d0463          	beqz	s10,7264 <_vsnprintf+0x4954>
    7260:	1220106f          	j	8382 <_vsnprintf+0x5a72>
    7264:	3d6d91e3          	bne	s11,s6,7e26 <_vsnprintf+0x5516>
    7268:	4d01                	li	s10,0
    726a:	e98fe06f          	j	5902 <_vsnprintf+0x2ff2>
    726e:	0001                	nop
    7270:	588dce8b          	th.lwia	t4,(s11),8,0
    7274:	917fc06f          	j	3b8a <_vsnprintf+0x127a>
    7278:	00278eb3          	add	t4,a5,sp
    727c:	05800713          	li	a4,88
    7280:	00278d13          	addi	s10,a5,2
    7284:	03000793          	li	a5,48
    7288:	02ee8823          	sb	a4,48(t4)
    728c:	02fe88a3          	sb	a5,49(t4)
    7290:	4b81                	li	s7,0
    7292:	f1ffd06f          	j	51b0 <_vsnprintf+0x28a0>
    7296:	00267e93          	andi	t4,a2,2
    729a:	380e8fe3          	beqz	t4,7e38 <_vsnprintf+0x5528>
    729e:	6e02                	ld	t3,0(sp)
    72a0:	a8afe06f          	j	552a <_vsnprintf+0x2c1a>
    72a4:	47a9                	li	a5,10
    72a6:	8b2e                	mv	s6,a1
    72a8:	86be                	mv	a3,a5
    72aa:	89ffc06f          	j	3b48 <_vsnprintf+0x1238>
    72ae:	ec46                	sd	a7,24(sp)
    72b0:	f05a                	sd	s6,32(sp)
    72b2:	e43fe06f          	j	60f4 <_vsnprintf+0x37e4>
    72b6:	340889e3          	beqz	a7,7e08 <_vsnprintf+0x54f8>
    72ba:	0012fd93          	andi	s11,t0,1
    72be:	7e0d80e3          	beqz	s11,829e <_vsnprintf+0x598e>
    72c2:	000e4463          	bltz	t3,72ca <_vsnprintf+0x49ba>
    72c6:	3ec0106f          	j	86b2 <_vsnprintf+0x5da2>
    72ca:	7c0c3d0b          	th.extu	s10,s8,31,0
    72ce:	38fd                	addiw	a7,a7,-1
    72d0:	01a7f463          	bgeu	a5,s10,72d8 <_vsnprintf+0x49c8>
    72d4:	b67fd06f          	j	4e3a <_vsnprintf+0x252a>
    72d8:	7c08b68b          	th.extu	a3,a7,31,0
    72dc:	00d7e463          	bltu	a5,a3,72e4 <_vsnprintf+0x49d4>
    72e0:	4d60106f          	j	87b6 <_vsnprintf+0x5ea6>
    72e4:	02000d93          	li	s11,32
    72e8:	40fd8533          	sub	a0,s11,a5
    72ec:	00757e93          	andi	t4,a0,7
    72f0:	00f30633          	add	a2,t1,a5
    72f4:	03000b13          	li	s6,48
    72f8:	060e8763          	beqz	t4,7366 <_vsnprintf+0x4a56>
    72fc:	0785                	addi	a5,a5,1
    72fe:	18165b0b          	th.sbia	s6,(a2),1,0
    7302:	0cd78463          	beq	a5,a3,73ca <_vsnprintf+0x4aba>
    7306:	4f05                	li	t5,1
    7308:	05ee8f63          	beq	t4,t5,7366 <_vsnprintf+0x4a56>
    730c:	4a89                	li	s5,2
    730e:	055e8763          	beq	t4,s5,735c <_vsnprintf+0x4a4c>
    7312:	428d                	li	t0,3
    7314:	025e8f63          	beq	t4,t0,7352 <_vsnprintf+0x4a42>
    7318:	4c91                	li	s9,4
    731a:	039e8763          	beq	t4,s9,7348 <_vsnprintf+0x4a38>
    731e:	4c15                	li	s8,5
    7320:	018e8f63          	beq	t4,s8,733e <_vsnprintf+0x4a2e>
    7324:	4b99                	li	s7,6
    7326:	017e8763          	beq	t4,s7,7334 <_vsnprintf+0x4a24>
    732a:	0785                	addi	a5,a5,1
    732c:	18165b0b          	th.sbia	s6,(a2),1,0
    7330:	08d78d63          	beq	a5,a3,73ca <_vsnprintf+0x4aba>
    7334:	0785                	addi	a5,a5,1
    7336:	18165b0b          	th.sbia	s6,(a2),1,0
    733a:	08d78863          	beq	a5,a3,73ca <_vsnprintf+0x4aba>
    733e:	0785                	addi	a5,a5,1
    7340:	18165b0b          	th.sbia	s6,(a2),1,0
    7344:	08d78363          	beq	a5,a3,73ca <_vsnprintf+0x4aba>
    7348:	0785                	addi	a5,a5,1
    734a:	18165b0b          	th.sbia	s6,(a2),1,0
    734e:	06d78e63          	beq	a5,a3,73ca <_vsnprintf+0x4aba>
    7352:	0785                	addi	a5,a5,1
    7354:	18165b0b          	th.sbia	s6,(a2),1,0
    7358:	06d78963          	beq	a5,a3,73ca <_vsnprintf+0x4aba>
    735c:	0785                	addi	a5,a5,1
    735e:	18165b0b          	th.sbia	s6,(a2),1,0
    7362:	06d78463          	beq	a5,a3,73ca <_vsnprintf+0x4aba>
    7366:	07b78863          	beq	a5,s11,73d6 <_vsnprintf+0x4ac6>
    736a:	00178f93          	addi	t6,a5,1
    736e:	01660023          	sb	s6,0(a2)
    7372:	04df8c63          	beq	t6,a3,73ca <_vsnprintf+0x4aba>
    7376:	00278393          	addi	t2,a5,2
    737a:	016600a3          	sb	s6,1(a2)
    737e:	04d38663          	beq	t2,a3,73ca <_vsnprintf+0x4aba>
    7382:	00378713          	addi	a4,a5,3
    7386:	01660123          	sb	s6,2(a2)
    738a:	04d70063          	beq	a4,a3,73ca <_vsnprintf+0x4aba>
    738e:	00478d13          	addi	s10,a5,4
    7392:	016601a3          	sb	s6,3(a2)
    7396:	02dd0a63          	beq	s10,a3,73ca <_vsnprintf+0x4aba>
    739a:	00578513          	addi	a0,a5,5
    739e:	01660223          	sb	s6,4(a2)
    73a2:	02d50463          	beq	a0,a3,73ca <_vsnprintf+0x4aba>
    73a6:	00678e93          	addi	t4,a5,6
    73aa:	016602a3          	sb	s6,5(a2)
    73ae:	00de8e63          	beq	t4,a3,73ca <_vsnprintf+0x4aba>
    73b2:	00778f13          	addi	t5,a5,7
    73b6:	01660323          	sb	s6,6(a2)
    73ba:	00df0863          	beq	t5,a3,73ca <_vsnprintf+0x4aba>
    73be:	016603a3          	sb	s6,7(a2)
    73c2:	07a1                	addi	a5,a5,8
    73c4:	0621                	addi	a2,a2,8
    73c6:	fad790e3          	bne	a5,a3,7366 <_vsnprintf+0x4a56>
    73ca:	02000793          	li	a5,32
    73ce:	00f68463          	beq	a3,a5,73d6 <_vsnprintf+0x4ac6>
    73d2:	b71fd06f          	j	4f42 <_vsnprintf+0x2632>
    73d6:	898d                	andi	a1,a1,3
    73d8:	c199                	beqz	a1,73de <_vsnprintf+0x4ace>
    73da:	1170106f          	j	8cf0 <_vsnprintf+0x63e0>
    73de:	02000693          	li	a3,32
    73e2:	6116f463          	bgeu	a3,a7,79ea <_vsnprintf+0x50da>
    73e6:	7c08bb8b          	th.extu	s7,a7,31,0
    73ea:	8dc2                	mv	s11,a6
    73ec:	8d36                	mv	s10,a3
    73ee:	4b01                	li	s6,0
    73f0:	b85fd06f          	j	4f74 <_vsnprintf+0x2664>
    73f4:	02b00513          	li	a0,43
    73f8:	feae0023          	sb	a0,-32(t3)
    73fc:	a5efc06f          	j	365a <_vsnprintf+0xd4a>
    7400:	898d                	andi	a1,a1,3
    7402:	c199                	beqz	a1,7408 <_vsnprintf+0x4af8>
    7404:	2620106f          	j	8666 <_vsnprintf+0x5d56>
    7408:	02000693          	li	a3,32
    740c:	0316f763          	bgeu	a3,a7,743a <_vsnprintf+0x4b2a>
    7410:	7c08bb8b          	th.extu	s7,a7,31,0
    7414:	8dc2                	mv	s11,a6
    7416:	8c36                	mv	s8,a3
    7418:	4b01                	li	s6,0
    741a:	daaff06f          	j	69c4 <_vsnprintf+0x40b4>
    741e:	fe0d81e3          	beqz	s11,7400 <_vsnprintf+0x4af0>
    7422:	7c08b68b          	th.extu	a3,a7,31,0
    7426:	00d7f463          	bgeu	a5,a3,742e <_vsnprintf+0x4b1e>
    742a:	8edfe06f          	j	5d16 <_vsnprintf+0x3406>
    742e:	0035fc13          	andi	s8,a1,3
    7432:	000c0463          	beqz	s8,743a <_vsnprintf+0x4b2a>
    7436:	2300106f          	j	8666 <_vsnprintf+0x5d56>
    743a:	8dc2                	mv	s11,a6
    743c:	04f14503          	lbu	a0,79(sp)
    7440:	6802                	ld	a6,0(sp)
    7442:	02000c13          	li	s8,32
    7446:	4b01                	li	s6,0
    7448:	b63fe06f          	j	5faa <_vsnprintf+0x369a>
    744c:	4b81                	li	s7,0
    744e:	963fd06f          	j	4db0 <_vsnprintf+0x24a0>
    7452:	47c1                	li	a5,16
    7454:	95dfd06f          	j	4db0 <_vsnprintf+0x24a0>
    7458:	ec46                	sd	a7,24(sp)
    745a:	fd515b8b          	th.sdd	s7,s5,(sp),2,4
    745e:	b4afc06f          	j	37a8 <_vsnprintf+0xe98>
    7462:	220e47e3          	bltz	t3,7e90 <_vsnprintf+0x5580>
    7466:	004afe13          	andi	t3,s5,4
    746a:	000e1463          	bnez	t3,7472 <_vsnprintf+0x4b62>
    746e:	2920106f          	j	8700 <_vsnprintf+0x5df0>
    7472:	00278d33          	add	s10,a5,sp
    7476:	02b00513          	li	a0,43
    747a:	02ad0823          	sb	a0,48(s10)
    747e:	6302                	ld	t1,0(sp)
    7480:	00178c13          	addi	s8,a5,1
    7484:	4b09                	li	s6,2
    7486:	d10fd06f          	j	4996 <_vsnprintf+0x2086>
    748a:	7c0c3c0b          	th.extu	s8,s8,31,0
    748e:	0187e463          	bltu	a5,s8,7496 <_vsnprintf+0x4b86>
    7492:	7020106f          	j	8b94 <_vsnprintf+0x6284>
    7496:	0015fd93          	andi	s11,a1,1
    749a:	4881                	li	a7,0
    749c:	f7cfe06f          	j	5c18 <_vsnprintf+0x3308>
    74a0:	7a088ee3          	beqz	a7,845c <_vsnprintf+0x5b4c>
    74a4:	001e7c93          	andi	s9,t3,1
    74a8:	7c0c370b          	th.extu	a4,s8,31,0
    74ac:	000c9463          	bnez	s9,74b4 <_vsnprintf+0x4ba4>
    74b0:	0d80106f          	j	8588 <_vsnprintf+0x5c78>
    74b4:	0eed7763          	bgeu	s10,a4,75a2 <_vsnprintf+0x4c92>
    74b8:	02000313          	li	t1,32
    74bc:	41a30fb3          	sub	t6,t1,s10
    74c0:	007fff13          	andi	t5,t6,7
    74c4:	01ab0533          	add	a0,s6,s10
    74c8:	03000393          	li	t2,48
    74cc:	060f0763          	beqz	t5,753a <_vsnprintf+0x4c2a>
    74d0:	0d05                	addi	s10,s10,1
    74d2:	1815538b          	th.sbia	t2,(a0),1,0
    74d6:	0ced7463          	bgeu	s10,a4,759e <_vsnprintf+0x4c8e>
    74da:	4585                	li	a1,1
    74dc:	04bf0f63          	beq	t5,a1,753a <_vsnprintf+0x4c2a>
    74e0:	4e09                	li	t3,2
    74e2:	05cf0763          	beq	t5,t3,7530 <_vsnprintf+0x4c20>
    74e6:	478d                	li	a5,3
    74e8:	02ff0f63          	beq	t5,a5,7526 <_vsnprintf+0x4c16>
    74ec:	4d91                	li	s11,4
    74ee:	03bf0763          	beq	t5,s11,751c <_vsnprintf+0x4c0c>
    74f2:	4295                	li	t0,5
    74f4:	005f0f63          	beq	t5,t0,7512 <_vsnprintf+0x4c02>
    74f8:	4f99                	li	t6,6
    74fa:	01ff0763          	beq	t5,t6,7508 <_vsnprintf+0x4bf8>
    74fe:	0d05                	addi	s10,s10,1
    7500:	1815538b          	th.sbia	t2,(a0),1,0
    7504:	08ed7d63          	bgeu	s10,a4,759e <_vsnprintf+0x4c8e>
    7508:	0d05                	addi	s10,s10,1
    750a:	1815538b          	th.sbia	t2,(a0),1,0
    750e:	08ed7863          	bgeu	s10,a4,759e <_vsnprintf+0x4c8e>
    7512:	0d05                	addi	s10,s10,1
    7514:	1815538b          	th.sbia	t2,(a0),1,0
    7518:	08ed7363          	bgeu	s10,a4,759e <_vsnprintf+0x4c8e>
    751c:	0d05                	addi	s10,s10,1
    751e:	1815538b          	th.sbia	t2,(a0),1,0
    7522:	06ed7e63          	bgeu	s10,a4,759e <_vsnprintf+0x4c8e>
    7526:	0d05                	addi	s10,s10,1
    7528:	1815538b          	th.sbia	t2,(a0),1,0
    752c:	06ed7963          	bgeu	s10,a4,759e <_vsnprintf+0x4c8e>
    7530:	0d05                	addi	s10,s10,1
    7532:	1815538b          	th.sbia	t2,(a0),1,0
    7536:	06ed7463          	bgeu	s10,a4,759e <_vsnprintf+0x4c8e>
    753a:	066d0263          	beq	s10,t1,759e <_vsnprintf+0x4c8e>
    753e:	0d05                	addi	s10,s10,1
    7540:	00750023          	sb	t2,0(a0)
    7544:	8f6a                	mv	t5,s10
    7546:	04ed7c63          	bgeu	s10,a4,759e <_vsnprintf+0x4c8e>
    754a:	0d05                	addi	s10,s10,1
    754c:	007500a3          	sb	t2,1(a0)
    7550:	04ed7763          	bgeu	s10,a4,759e <_vsnprintf+0x4c8e>
    7554:	002f0d13          	addi	s10,t5,2
    7558:	00750123          	sb	t2,2(a0)
    755c:	04ed7163          	bgeu	s10,a4,759e <_vsnprintf+0x4c8e>
    7560:	003f0d13          	addi	s10,t5,3
    7564:	007501a3          	sb	t2,3(a0)
    7568:	02ed7b63          	bgeu	s10,a4,759e <_vsnprintf+0x4c8e>
    756c:	004f0d13          	addi	s10,t5,4
    7570:	00750223          	sb	t2,4(a0)
    7574:	02ed7563          	bgeu	s10,a4,759e <_vsnprintf+0x4c8e>
    7578:	005f0d13          	addi	s10,t5,5
    757c:	007502a3          	sb	t2,5(a0)
    7580:	00ed7f63          	bgeu	s10,a4,759e <_vsnprintf+0x4c8e>
    7584:	006f0d13          	addi	s10,t5,6
    7588:	00750323          	sb	t2,6(a0)
    758c:	00ed7963          	bgeu	s10,a4,759e <_vsnprintf+0x4c8e>
    7590:	007503a3          	sb	t2,7(a0)
    7594:	007f0d13          	addi	s10,t5,7
    7598:	0521                	addi	a0,a0,8
    759a:	faed60e3          	bltu	s10,a4,753a <_vsnprintf+0x4c2a>
    759e:	620c84e3          	beqz	s9,83c6 <_vsnprintf+0x5ab6>
    75a2:	7c08b78b          	th.extu	a5,a7,31,0
    75a6:	00fd6463          	bltu	s10,a5,75ae <_vsnprintf+0x4c9e>
    75aa:	6020106f          	j	8bac <_vsnprintf+0x629c>
    75ae:	02000c93          	li	s9,32
    75b2:	41ac83b3          	sub	t2,s9,s10
    75b6:	0073fe13          	andi	t3,t2,7
    75ba:	01ab05b3          	add	a1,s6,s10
    75be:	03000313          	li	t1,48
    75c2:	060e0763          	beqz	t3,7630 <_vsnprintf+0x4d20>
    75c6:	0d05                	addi	s10,s10,1
    75c8:	1815d30b          	th.sbia	t1,(a1),1,0
    75cc:	0da78463          	beq	a5,s10,7694 <_vsnprintf+0x4d84>
    75d0:	4d85                	li	s11,1
    75d2:	05be0f63          	beq	t3,s11,7630 <_vsnprintf+0x4d20>
    75d6:	4289                	li	t0,2
    75d8:	045e0763          	beq	t3,t0,7626 <_vsnprintf+0x4d16>
    75dc:	4f8d                	li	t6,3
    75de:	03fe0f63          	beq	t3,t6,761c <_vsnprintf+0x4d0c>
    75e2:	4f11                	li	t5,4
    75e4:	03ee0763          	beq	t3,t5,7612 <_vsnprintf+0x4d02>
    75e8:	4515                	li	a0,5
    75ea:	00ae0f63          	beq	t3,a0,7608 <_vsnprintf+0x4cf8>
    75ee:	4719                	li	a4,6
    75f0:	00ee0763          	beq	t3,a4,75fe <_vsnprintf+0x4cee>
    75f4:	0d05                	addi	s10,s10,1
    75f6:	1815d30b          	th.sbia	t1,(a1),1,0
    75fa:	09a78d63          	beq	a5,s10,7694 <_vsnprintf+0x4d84>
    75fe:	0d05                	addi	s10,s10,1
    7600:	1815d30b          	th.sbia	t1,(a1),1,0
    7604:	09a78863          	beq	a5,s10,7694 <_vsnprintf+0x4d84>
    7608:	0d05                	addi	s10,s10,1
    760a:	1815d30b          	th.sbia	t1,(a1),1,0
    760e:	09a78363          	beq	a5,s10,7694 <_vsnprintf+0x4d84>
    7612:	0d05                	addi	s10,s10,1
    7614:	1815d30b          	th.sbia	t1,(a1),1,0
    7618:	07a78e63          	beq	a5,s10,7694 <_vsnprintf+0x4d84>
    761c:	0d05                	addi	s10,s10,1
    761e:	1815d30b          	th.sbia	t1,(a1),1,0
    7622:	07a78963          	beq	a5,s10,7694 <_vsnprintf+0x4d84>
    7626:	0d05                	addi	s10,s10,1
    7628:	1815d30b          	th.sbia	t1,(a1),1,0
    762c:	07a78463          	beq	a5,s10,7694 <_vsnprintf+0x4d84>
    7630:	179d07e3          	beq	s10,s9,7f9e <_vsnprintf+0x568e>
    7634:	0d05                	addi	s10,s10,1
    7636:	00658023          	sb	t1,0(a1)
    763a:	83ea                	mv	t2,s10
    763c:	05a78c63          	beq	a5,s10,7694 <_vsnprintf+0x4d84>
    7640:	0d05                	addi	s10,s10,1
    7642:	006580a3          	sb	t1,1(a1)
    7646:	05a78763          	beq	a5,s10,7694 <_vsnprintf+0x4d84>
    764a:	00238d13          	addi	s10,t2,2
    764e:	00658123          	sb	t1,2(a1)
    7652:	05a78163          	beq	a5,s10,7694 <_vsnprintf+0x4d84>
    7656:	00338d13          	addi	s10,t2,3
    765a:	006581a3          	sb	t1,3(a1)
    765e:	03a78b63          	beq	a5,s10,7694 <_vsnprintf+0x4d84>
    7662:	00438d13          	addi	s10,t2,4
    7666:	00658223          	sb	t1,4(a1)
    766a:	03a78563          	beq	a5,s10,7694 <_vsnprintf+0x4d84>
    766e:	00538d13          	addi	s10,t2,5
    7672:	006582a3          	sb	t1,5(a1)
    7676:	01a78f63          	beq	a5,s10,7694 <_vsnprintf+0x4d84>
    767a:	00638d13          	addi	s10,t2,6
    767e:	00658323          	sb	t1,6(a1)
    7682:	01a78963          	beq	a5,s10,7694 <_vsnprintf+0x4d84>
    7686:	006583a3          	sb	t1,7(a1)
    768a:	00738d13          	addi	s10,t2,7
    768e:	05a1                	addi	a1,a1,8
    7690:	fba790e3          	bne	a5,s10,7630 <_vsnprintf+0x4d20>
    7694:	4a0e9be3          	bnez	t4,834a <_vsnprintf+0x5a3a>
    7698:	819d0663          	beq	s10,s9,66a4 <_vsnprintf+0x3d94>
    769c:	00367b93          	andi	s7,a2,3
    76a0:	000b8463          	beqz	s7,76a8 <_vsnprintf+0x4d98>
    76a4:	3160106f          	j	89ba <_vsnprintf+0x60aa>
    76a8:	8c3e                	mv	s8,a5
    76aa:	10fd67e3          	bltu	s10,a5,7fb8 <_vsnprintf+0x56a8>
    76ae:	6382                	ld	t2,0(sp)
    76b0:	ffdfe06f          	j	66ac <_vsnprintf+0x3d9c>
    76b4:	4d09                	li	s10,2
    76b6:	500b83e3          	beqz	s7,83bc <_vsnprintf+0x5aac>
    76ba:	4b41                	li	s6,16
    76bc:	57668be3          	beq	a3,s6,8432 <_vsnprintf+0x5b22>
    76c0:	4a89                	li	s5,2
    76c2:	555688e3          	beq	a3,s5,8412 <_vsnprintf+0x5b02>
    76c6:	02000593          	li	a1,32
    76ca:	5cb71663          	bne	a4,a1,7c96 <_vsnprintf+0x5386>
    76ce:	003e7513          	andi	a0,t3,3
    76d2:	c119                	beqz	a0,76d8 <_vsnprintf+0x4dc8>
    76d4:	ce5fd06f          	j	53b8 <_vsnprintf+0x2aa8>
    76d8:	02000713          	li	a4,32
    76dc:	01176463          	bltu	a4,a7,76e4 <_vsnprintf+0x4dd4>
    76e0:	cd9fd06f          	j	53b8 <_vsnprintf+0x2aa8>
    76e4:	7c08bc0b          	th.extu	s8,a7,31,0
    76e8:	6602                	ld	a2,0(sp)
    76ea:	ec3a                	sd	a4,24(sp)
    76ec:	f046                	sd	a7,32(sp)
    76ee:	40c70cb3          	sub	s9,a4,a2
    76f2:	fffcc813          	not	a6,s9
    76f6:	40c80eb3          	sub	t4,a6,a2
    76fa:	018e8b33          	add	s6,t4,s8
    76fe:	02000513          	li	a0,32
    7702:	86a6                	mv	a3,s1
    7704:	85ca                	mv	a1,s2
    7706:	007b7a93          	andi	s5,s6,7
    770a:	00160b13          	addi	s6,a2,1
    770e:	9402                	jalr	s0
    7710:	016c8533          	add	a0,s9,s6
    7714:	6762                	ld	a4,24(sp)
    7716:	7882                	ld	a7,32(sp)
    7718:	17857263          	bgeu	a0,s8,787c <_vsnprintf+0x4f6c>
    771c:	0c0a8763          	beqz	s5,77ea <_vsnprintf+0x4eda>
    7720:	4305                	li	t1,1
    7722:	0a6a8563          	beq	s5,t1,77cc <_vsnprintf+0x4ebc>
    7726:	4289                	li	t0,2
    7728:	085a8763          	beq	s5,t0,77b6 <_vsnprintf+0x4ea6>
    772c:	438d                	li	t2,3
    772e:	067a8963          	beq	s5,t2,77a0 <_vsnprintf+0x4e90>
    7732:	4f11                	li	t5,4
    7734:	05ea8b63          	beq	s5,t5,778a <_vsnprintf+0x4e7a>
    7738:	4695                	li	a3,5
    773a:	02da8d63          	beq	s5,a3,7774 <_vsnprintf+0x4e64>
    773e:	4799                	li	a5,6
    7740:	00fa8f63          	beq	s5,a5,775e <_vsnprintf+0x4e4e>
    7744:	ec46                	sd	a7,24(sp)
    7746:	f03a                	sd	a4,32(sp)
    7748:	865a                	mv	a2,s6
    774a:	86a6                	mv	a3,s1
    774c:	85ca                	mv	a1,s2
    774e:	02000513          	li	a0,32
    7752:	6b82                	ld	s7,0(sp)
    7754:	9402                	jalr	s0
    7756:	68e2                	ld	a7,24(sp)
    7758:	7702                	ld	a4,32(sp)
    775a:	002b8b13          	addi	s6,s7,2
    775e:	ec46                	sd	a7,24(sp)
    7760:	f03a                	sd	a4,32(sp)
    7762:	865a                	mv	a2,s6
    7764:	86a6                	mv	a3,s1
    7766:	85ca                	mv	a1,s2
    7768:	02000513          	li	a0,32
    776c:	9402                	jalr	s0
    776e:	68e2                	ld	a7,24(sp)
    7770:	7702                	ld	a4,32(sp)
    7772:	0b05                	addi	s6,s6,1
    7774:	ec46                	sd	a7,24(sp)
    7776:	f03a                	sd	a4,32(sp)
    7778:	865a                	mv	a2,s6
    777a:	86a6                	mv	a3,s1
    777c:	85ca                	mv	a1,s2
    777e:	02000513          	li	a0,32
    7782:	9402                	jalr	s0
    7784:	68e2                	ld	a7,24(sp)
    7786:	7702                	ld	a4,32(sp)
    7788:	0b05                	addi	s6,s6,1
    778a:	ec46                	sd	a7,24(sp)
    778c:	f03a                	sd	a4,32(sp)
    778e:	865a                	mv	a2,s6
    7790:	86a6                	mv	a3,s1
    7792:	85ca                	mv	a1,s2
    7794:	02000513          	li	a0,32
    7798:	9402                	jalr	s0
    779a:	68e2                	ld	a7,24(sp)
    779c:	7702                	ld	a4,32(sp)
    779e:	0b05                	addi	s6,s6,1
    77a0:	ec46                	sd	a7,24(sp)
    77a2:	f03a                	sd	a4,32(sp)
    77a4:	865a                	mv	a2,s6
    77a6:	86a6                	mv	a3,s1
    77a8:	85ca                	mv	a1,s2
    77aa:	02000513          	li	a0,32
    77ae:	9402                	jalr	s0
    77b0:	68e2                	ld	a7,24(sp)
    77b2:	7702                	ld	a4,32(sp)
    77b4:	0b05                	addi	s6,s6,1
    77b6:	ec46                	sd	a7,24(sp)
    77b8:	f03a                	sd	a4,32(sp)
    77ba:	865a                	mv	a2,s6
    77bc:	86a6                	mv	a3,s1
    77be:	85ca                	mv	a1,s2
    77c0:	02000513          	li	a0,32
    77c4:	9402                	jalr	s0
    77c6:	68e2                	ld	a7,24(sp)
    77c8:	7702                	ld	a4,32(sp)
    77ca:	0b05                	addi	s6,s6,1
    77cc:	ec46                	sd	a7,24(sp)
    77ce:	f03a                	sd	a4,32(sp)
    77d0:	865a                	mv	a2,s6
    77d2:	86a6                	mv	a3,s1
    77d4:	85ca                	mv	a1,s2
    77d6:	02000513          	li	a0,32
    77da:	9402                	jalr	s0
    77dc:	0b05                	addi	s6,s6,1
    77de:	016c8fb3          	add	t6,s9,s6
    77e2:	68e2                	ld	a7,24(sp)
    77e4:	7702                	ld	a4,32(sp)
    77e6:	098ffb63          	bgeu	t6,s8,787c <_vsnprintf+0x4f6c>
    77ea:	ec6e                	sd	s11,24(sp)
    77ec:	8dc6                	mv	s11,a7
    77ee:	f03a                	sd	a4,32(sp)
    77f0:	865a                	mv	a2,s6
    77f2:	86a6                	mv	a3,s1
    77f4:	85ca                	mv	a1,s2
    77f6:	02000513          	li	a0,32
    77fa:	9402                	jalr	s0
    77fc:	001b0a93          	addi	s5,s6,1
    7800:	8656                	mv	a2,s5
    7802:	86a6                	mv	a3,s1
    7804:	85ca                	mv	a1,s2
    7806:	02000513          	li	a0,32
    780a:	9402                	jalr	s0
    780c:	002b0b93          	addi	s7,s6,2
    7810:	865e                	mv	a2,s7
    7812:	86a6                	mv	a3,s1
    7814:	85ca                	mv	a1,s2
    7816:	02000513          	li	a0,32
    781a:	9402                	jalr	s0
    781c:	003b0a93          	addi	s5,s6,3
    7820:	8656                	mv	a2,s5
    7822:	86a6                	mv	a3,s1
    7824:	85ca                	mv	a1,s2
    7826:	02000513          	li	a0,32
    782a:	9402                	jalr	s0
    782c:	004b0b93          	addi	s7,s6,4
    7830:	865e                	mv	a2,s7
    7832:	86a6                	mv	a3,s1
    7834:	85ca                	mv	a1,s2
    7836:	02000513          	li	a0,32
    783a:	9402                	jalr	s0
    783c:	005b0a93          	addi	s5,s6,5
    7840:	8656                	mv	a2,s5
    7842:	86a6                	mv	a3,s1
    7844:	85ca                	mv	a1,s2
    7846:	02000513          	li	a0,32
    784a:	9402                	jalr	s0
    784c:	006b0b93          	addi	s7,s6,6
    7850:	86a6                	mv	a3,s1
    7852:	865e                	mv	a2,s7
    7854:	85ca                	mv	a1,s2
    7856:	02000513          	li	a0,32
    785a:	9402                	jalr	s0
    785c:	007b0a93          	addi	s5,s6,7
    7860:	86a6                	mv	a3,s1
    7862:	8656                	mv	a2,s5
    7864:	85ca                	mv	a1,s2
    7866:	02000513          	li	a0,32
    786a:	9402                	jalr	s0
    786c:	0b21                	addi	s6,s6,8
    786e:	016c88b3          	add	a7,s9,s6
    7872:	7702                	ld	a4,32(sp)
    7874:	f788ede3          	bltu	a7,s8,77ee <_vsnprintf+0x4ede>
    7878:	88ee                	mv	a7,s11
    787a:	6de2                	ld	s11,24(sp)
    787c:	6c82                	ld	s9,0(sp)
    787e:	fffc0e13          	addi	t3,s8,-1
    7882:	00170593          	addi	a1,a4,1
    7886:	40ee07b3          	sub	a5,t3,a4
    788a:	00bc3633          	sltu	a2,s8,a1
    788e:	42c0178b          	th.mvnez	a5,zero,a2
    7892:	001c8e93          	addi	t4,s9,1
    7896:	03010813          	addi	a6,sp,48
    789a:	01d78e33          	add	t3,a5,t4
    789e:	c319                	beqz	a4,78a4 <_vsnprintf+0x4f94>
    78a0:	b1ffd06f          	j	53be <_vsnprintf+0x2aae>
    78a4:	c7ffd06f          	j	5522 <_vsnprintf+0x2c12>
    78a8:	4805                	li	a6,1
    78aa:	010d0463          	beq	s10,a6,78b2 <_vsnprintf+0x4fa2>
    78ae:	1040106f          	j	89b2 <_vsnprintf+0x60a2>
    78b2:	678d                	lui	a5,0x3
    78b4:	05878293          	addi	t0,a5,88 # 3058 <_vsnprintf+0x748>
    78b8:	02511823          	sh	t0,48(sp)
    78bc:	00457f93          	andi	t6,a0,4
    78c0:	1a0f8ee3          	beqz	t6,827c <_vsnprintf+0x596c>
    78c4:	4b89                	li	s7,2
    78c6:	87de                	mv	a5,s7
    78c8:	4ac1                	li	s5,16
    78ca:	ce6fd06f          	j	4db0 <_vsnprintf+0x24a0>
    78ce:	7c0c350b          	th.extu	a0,s8,31,0
    78d2:	00a76463          	bltu	a4,a0,78da <_vsnprintf+0x4fca>
    78d6:	2f00106f          	j	8bc6 <_vsnprintf+0x62b6>
    78da:	001e7b13          	andi	s6,t3,1
    78de:	aaaff06f          	j	6b88 <_vsnprintf+0x4278>
    78e2:	f2000353          	fmv.d.x	ft6,zero
    78e6:	a26513d3          	flt.d	t2,fa0,ft6
    78ea:	00038463          	beqz	t2,78f2 <_vsnprintf+0x4fe2>
    78ee:	91dfd06f          	j	520a <_vsnprintf+0x28fa>
    78f2:	77fd                	lui	a5,0xfffff
    78f4:	7ff78f93          	addi	t6,a5,2047 # fffffffffffff7ff <__kernel_stack+0xfffffffffff117ff>
    78f8:	01fb7b33          	and	s6,s6,t6
    78fc:	400b6e93          	ori	t4,s6,1024
    7900:	000e881b          	sext.w	a6,t4
    7904:	87c6                	mv	a5,a7
    7906:	876e                	mv	a4,s11
    7908:	f2068553          	fmv.d.x	fa0,a3
    790c:	a5bfc06f          	j	4366 <_vsnprintf+0x1a56>
    7910:	7c0c350b          	th.extu	a0,s8,31,0
    7914:	00ade463          	bltu	s11,a0,791c <_vsnprintf+0x500c>
    7918:	2c80106f          	j	8be0 <_vsnprintf+0x62d0>
    791c:	00167b13          	andi	s6,a2,1
    7920:	f64ff06f          	j	7084 <_vsnprintf+0x4774>
    7924:	0045fc13          	andi	s8,a1,4
    7928:	02b00513          	li	a0,43
    792c:	000c1863          	bnez	s8,793c <_vsnprintf+0x502c>
    7930:	008d7593          	andi	a1,s10,8
    7934:	500587e3          	beqz	a1,8642 <_vsnprintf+0x5d32>
    7938:	02000513          	li	a0,32
    793c:	6302                	ld	t1,0(sp)
    793e:	02a10823          	sb	a0,48(sp)
    7942:	4c05                	li	s8,1
    7944:	4b09                	li	s6,2
    7946:	03010b93          	addi	s7,sp,48
    794a:	84cfd06f          	j	4996 <_vsnprintf+0x2086>
    794e:	0e0ec9e3          	bltz	t4,8240 <_vsnprintf+0x5930>
    7952:	0046fe93          	andi	t4,a3,4
    7956:	3e0e87e3          	beqz	t4,8544 <_vsnprintf+0x5c34>
    795a:	002782b3          	add	t0,a5,sp
    795e:	02b00513          	li	a0,43
    7962:	02a28823          	sb	a0,48(t0)
    7966:	8dc2                	mv	s11,a6
    7968:	00178c13          	addi	s8,a5,1
    796c:	6802                	ld	a6,0(sp)
    796e:	4b09                	li	s6,2
    7970:	e3afe06f          	j	5faa <_vsnprintf+0x369a>
    7974:	5e0e9163          	bnez	t4,7f56 <_vsnprintf+0x5646>
    7978:	4d01                	li	s10,0
    797a:	003e7e13          	andi	t3,t3,3
    797e:	000e0463          	beqz	t3,7986 <_vsnprintf+0x5076>
    7982:	a37fd06f          	j	53b8 <_vsnprintf+0x2aa8>
    7986:	02000713          	li	a4,32
    798a:	7c08bc0b          	th.extu	s8,a7,31,0
    798e:	d5176de3          	bltu	a4,a7,76e8 <_vsnprintf+0x4dd8>
    7992:	a27fd06f          	j	53b8 <_vsnprintf+0x2aa8>
    7996:	0001                	nop
    7998:	4b81                	li	s7,0
    799a:	020d0293          	addi	t0,s10,32
    799e:	03010e93          	addi	t4,sp,48
    79a2:	01d28fb3          	add	t6,t0,t4
    79a6:	05800713          	li	a4,88
    79aa:	03000e13          	li	t3,48
    79ae:	fcef8f23          	sb	a4,-34(t6)
    79b2:	fdcf8fa3          	sb	t3,-33(t6)
    79b6:	0045ff13          	andi	t5,a1,4
    79ba:	000f0563          	beqz	t5,79c4 <_vsnprintf+0x50b4>
    79be:	87ea                	mv	a5,s10
    79c0:	bf0fd06f          	j	4db0 <_vsnprintf+0x24a0>
    79c4:	89a1                	andi	a1,a1,8
    79c6:	e199                	bnez	a1,79cc <_vsnprintf+0x50bc>
    79c8:	993fc06f          	j	435a <_vsnprintf+0x1a4a>
    79cc:	87ea                	mv	a5,s10
    79ce:	811fd06f          	j	51de <_vsnprintf+0x28ce>
    79d2:	a00d82e3          	beqz	s11,73d6 <_vsnprintf+0x4ac6>
    79d6:	7c08b68b          	th.extu	a3,a7,31,0
    79da:	90d7e5e3          	bltu	a5,a3,72e4 <_vsnprintf+0x49d4>
    79de:	0035fd13          	andi	s10,a1,3
    79e2:	000d0463          	beqz	s10,79ea <_vsnprintf+0x50da>
    79e6:	30a0106f          	j	8cf0 <_vsnprintf+0x63e0>
    79ea:	04f14503          	lbu	a0,79(sp)
    79ee:	6382                	ld	t2,0(sp)
    79f0:	8dc2                	mv	s11,a6
    79f2:	02000d13          	li	s10,32
    79f6:	4b01                	li	s6,0
    79f8:	cbcfc06f          	j	3eb4 <_vsnprintf+0x15a4>
    79fc:	002b7b93          	andi	s7,s6,2
    7a00:	000b9463          	bnez	s7,7a08 <_vsnprintf+0x50f8>
    7a04:	ca7fd06f          	j	56aa <_vsnprintf+0x2d9a>
    7a08:	6b02                	ld	s6,0(sp)
    7a0a:	4b81                	li	s7,0
    7a0c:	e98fb06f          	j	30a4 <_vsnprintf+0x794>
    7a10:	4b89                	li	s7,2
    7a12:	4ac1                	li	s5,16
    7a14:	03010b13          	addi	s6,sp,48
    7a18:	fc6fd06f          	j	51de <_vsnprintf+0x28ce>
    7a1c:	020e8fe3          	beqz	t4,825a <_vsnprintf+0x594a>
    7a20:	040b9863          	bnez	s7,7a70 <_vsnprintf+0x5160>
    7a24:	00e50763          	beq	a0,a4,7a32 <_vsnprintf+0x5122>
    7a28:	7c08be8b          	th.extu	t4,a7,31,0
    7a2c:	8d5e                	mv	s10,s7
    7a2e:	c8ee96e3          	bne	t4,a4,76ba <_vsnprintf+0x4daa>
    7a32:	fff70793          	addi	a5,a4,-1
    7a36:	40079ae3          	bnez	a5,864a <_vsnprintf+0x5d3a>
    7a3a:	4741                	li	a4,16
    7a3c:	58e68de3          	beq	a3,a4,87d6 <_vsnprintf+0x5ec6>
    7a40:	4d09                	li	s10,2
    7a42:	01a69463          	bne	a3,s10,7a4a <_vsnprintf+0x513a>
    7a46:	2f00106f          	j	8d36 <_vsnprintf+0x6426>
    7a4a:	03000e93          	li	t4,48
    7a4e:	03d10823          	sb	t4,48(sp)
    7a52:	003e7e13          	andi	t3,t3,3
    7a56:	000e1463          	bnez	t3,7a5e <_vsnprintf+0x514e>
    7a5a:	2c60106f          	j	8d20 <_vsnprintf+0x6410>
    7a5e:	6e02                	ld	t3,0(sp)
    7a60:	8d5e                	mv	s10,s7
    7a62:	4705                	li	a4,1
    7a64:	95bfd06f          	j	53be <_vsnprintf+0x2aae>
    7a68:	3eec00e3          	beq	s8,a4,8648 <_vsnprintf+0x5d38>
    7a6c:	3ce88ee3          	beq	a7,a4,8648 <_vsnprintf+0x5d38>
    7a70:	4d01                	li	s10,0
    7a72:	b1a1                	j	76ba <_vsnprintf+0x4daa>
    7a74:	4d09                	li	s10,2
    7a76:	7c0c350b          	th.extu	a0,s8,31,0
    7a7a:	2e0b8663          	beqz	s7,7d66 <_vsnprintf+0x5456>
    7a7e:	4f41                	li	t5,16
    7a80:	49e68d63          	beq	a3,t5,7f1a <_vsnprintf+0x560a>
    7a84:	4789                	li	a5,2
    7a86:	40f687e3          	beq	a3,a5,8694 <_vsnprintf+0x5d84>
    7a8a:	02000f13          	li	t5,32
    7a8e:	29ed9d63          	bne	s11,t5,7d28 <_vsnprintf+0x5418>
    7a92:	00367d93          	andi	s11,a2,3
    7a96:	000d8463          	beqz	s11,7a9e <_vsnprintf+0x518e>
    7a9a:	e69fd06f          	j	5902 <_vsnprintf+0x2ff2>
    7a9e:	02000613          	li	a2,32
    7aa2:	01166463          	bltu	a2,a7,7aaa <_vsnprintf+0x519a>
    7aa6:	e5dfd06f          	j	5902 <_vsnprintf+0x2ff2>
    7aaa:	7c08bc0b          	th.extu	s8,a7,31,0
    7aae:	8db2                	mv	s11,a2
    7ab0:	6602                	ld	a2,0(sp)
    7ab2:	02000513          	li	a0,32
    7ab6:	ec46                	sd	a7,24(sp)
    7ab8:	40cd8cb3          	sub	s9,s11,a2
    7abc:	fffcc813          	not	a6,s9
    7ac0:	01880bb3          	add	s7,a6,s8
    7ac4:	40cb8b33          	sub	s6,s7,a2
    7ac8:	86a6                	mv	a3,s1
    7aca:	85ca                	mv	a1,s2
    7acc:	007b7b93          	andi	s7,s6,7
    7ad0:	00160b13          	addi	s6,a2,1
    7ad4:	9402                	jalr	s0
    7ad6:	016c8533          	add	a0,s9,s6
    7ada:	68e2                	ld	a7,24(sp)
    7adc:	15857663          	bgeu	a0,s8,7c28 <_vsnprintf+0x5318>
    7ae0:	0a0b8963          	beqz	s7,7b92 <_vsnprintf+0x5282>
    7ae4:	4705                	li	a4,1
    7ae6:	08eb8963          	beq	s7,a4,7b78 <_vsnprintf+0x5268>
    7aea:	4f89                	li	t6,2
    7aec:	07fb8d63          	beq	s7,t6,7b66 <_vsnprintf+0x5256>
    7af0:	468d                	li	a3,3
    7af2:	06db8163          	beq	s7,a3,7b54 <_vsnprintf+0x5244>
    7af6:	4f11                	li	t5,4
    7af8:	05eb8563          	beq	s7,t5,7b42 <_vsnprintf+0x5232>
    7afc:	4795                	li	a5,5
    7afe:	02fb8963          	beq	s7,a5,7b30 <_vsnprintf+0x5220>
    7b02:	4399                	li	t2,6
    7b04:	007b8d63          	beq	s7,t2,7b1e <_vsnprintf+0x520e>
    7b08:	6302                	ld	t1,0(sp)
    7b0a:	865a                	mv	a2,s6
    7b0c:	ec46                	sd	a7,24(sp)
    7b0e:	86a6                	mv	a3,s1
    7b10:	85ca                	mv	a1,s2
    7b12:	02000513          	li	a0,32
    7b16:	00230b13          	addi	s6,t1,2
    7b1a:	9402                	jalr	s0
    7b1c:	68e2                	ld	a7,24(sp)
    7b1e:	865a                	mv	a2,s6
    7b20:	ec46                	sd	a7,24(sp)
    7b22:	86a6                	mv	a3,s1
    7b24:	85ca                	mv	a1,s2
    7b26:	02000513          	li	a0,32
    7b2a:	9402                	jalr	s0
    7b2c:	68e2                	ld	a7,24(sp)
    7b2e:	0b05                	addi	s6,s6,1
    7b30:	865a                	mv	a2,s6
    7b32:	ec46                	sd	a7,24(sp)
    7b34:	86a6                	mv	a3,s1
    7b36:	85ca                	mv	a1,s2
    7b38:	02000513          	li	a0,32
    7b3c:	9402                	jalr	s0
    7b3e:	68e2                	ld	a7,24(sp)
    7b40:	0b05                	addi	s6,s6,1
    7b42:	865a                	mv	a2,s6
    7b44:	ec46                	sd	a7,24(sp)
    7b46:	86a6                	mv	a3,s1
    7b48:	85ca                	mv	a1,s2
    7b4a:	02000513          	li	a0,32
    7b4e:	9402                	jalr	s0
    7b50:	68e2                	ld	a7,24(sp)
    7b52:	0b05                	addi	s6,s6,1
    7b54:	865a                	mv	a2,s6
    7b56:	ec46                	sd	a7,24(sp)
    7b58:	86a6                	mv	a3,s1
    7b5a:	85ca                	mv	a1,s2
    7b5c:	02000513          	li	a0,32
    7b60:	9402                	jalr	s0
    7b62:	68e2                	ld	a7,24(sp)
    7b64:	0b05                	addi	s6,s6,1
    7b66:	865a                	mv	a2,s6
    7b68:	ec46                	sd	a7,24(sp)
    7b6a:	86a6                	mv	a3,s1
    7b6c:	85ca                	mv	a1,s2
    7b6e:	02000513          	li	a0,32
    7b72:	9402                	jalr	s0
    7b74:	68e2                	ld	a7,24(sp)
    7b76:	0b05                	addi	s6,s6,1
    7b78:	865a                	mv	a2,s6
    7b7a:	ec46                	sd	a7,24(sp)
    7b7c:	86a6                	mv	a3,s1
    7b7e:	85ca                	mv	a1,s2
    7b80:	02000513          	li	a0,32
    7b84:	9402                	jalr	s0
    7b86:	0b05                	addi	s6,s6,1
    7b88:	016c8eb3          	add	t4,s9,s6
    7b8c:	68e2                	ld	a7,24(sp)
    7b8e:	098efd63          	bgeu	t4,s8,7c28 <_vsnprintf+0x5318>
    7b92:	ec6e                	sd	s11,24(sp)
    7b94:	f06a                	sd	s10,32(sp)
    7b96:	8dd6                	mv	s11,s5
    7b98:	8d46                	mv	s10,a7
    7b9a:	865a                	mv	a2,s6
    7b9c:	86a6                	mv	a3,s1
    7b9e:	85ca                	mv	a1,s2
    7ba0:	02000513          	li	a0,32
    7ba4:	9402                	jalr	s0
    7ba6:	001b0b93          	addi	s7,s6,1
    7baa:	865e                	mv	a2,s7
    7bac:	86a6                	mv	a3,s1
    7bae:	85ca                	mv	a1,s2
    7bb0:	02000513          	li	a0,32
    7bb4:	9402                	jalr	s0
    7bb6:	002b0a93          	addi	s5,s6,2
    7bba:	8656                	mv	a2,s5
    7bbc:	86a6                	mv	a3,s1
    7bbe:	85ca                	mv	a1,s2
    7bc0:	02000513          	li	a0,32
    7bc4:	9402                	jalr	s0
    7bc6:	003b0b93          	addi	s7,s6,3
    7bca:	865e                	mv	a2,s7
    7bcc:	86a6                	mv	a3,s1
    7bce:	85ca                	mv	a1,s2
    7bd0:	02000513          	li	a0,32
    7bd4:	9402                	jalr	s0
    7bd6:	004b0a93          	addi	s5,s6,4
    7bda:	8656                	mv	a2,s5
    7bdc:	86a6                	mv	a3,s1
    7bde:	85ca                	mv	a1,s2
    7be0:	02000513          	li	a0,32
    7be4:	9402                	jalr	s0
    7be6:	005b0b93          	addi	s7,s6,5
    7bea:	865e                	mv	a2,s7
    7bec:	86a6                	mv	a3,s1
    7bee:	85ca                	mv	a1,s2
    7bf0:	02000513          	li	a0,32
    7bf4:	9402                	jalr	s0
    7bf6:	006b0a93          	addi	s5,s6,6
    7bfa:	86a6                	mv	a3,s1
    7bfc:	8656                	mv	a2,s5
    7bfe:	85ca                	mv	a1,s2
    7c00:	02000513          	li	a0,32
    7c04:	9402                	jalr	s0
    7c06:	007b0b93          	addi	s7,s6,7
    7c0a:	86a6                	mv	a3,s1
    7c0c:	865e                	mv	a2,s7
    7c0e:	85ca                	mv	a1,s2
    7c10:	02000513          	li	a0,32
    7c14:	0b21                	addi	s6,s6,8
    7c16:	9402                	jalr	s0
    7c18:	016c88b3          	add	a7,s9,s6
    7c1c:	f788efe3          	bltu	a7,s8,7b9a <_vsnprintf+0x528a>
    7c20:	88ea                	mv	a7,s10
    7c22:	8aee                	mv	s5,s11
    7c24:	6de2                	ld	s11,24(sp)
    7c26:	7d02                	ld	s10,32(sp)
    7c28:	6c82                	ld	s9,0(sp)
    7c2a:	fffc0e13          	addi	t3,s8,-1
    7c2e:	001d8593          	addi	a1,s11,1
    7c32:	41be02b3          	sub	t0,t3,s11
    7c36:	00bc3633          	sltu	a2,s8,a1
    7c3a:	42c0128b          	th.mvnez	t0,zero,a2
    7c3e:	001c8513          	addi	a0,s9,1
    7c42:	03010813          	addi	a6,sp,48
    7c46:	00a286b3          	add	a3,t0,a0
    7c4a:	000d8463          	beqz	s11,7c52 <_vsnprintf+0x5342>
    7c4e:	cbbfd06f          	j	5908 <_vsnprintf+0x2ff8>
    7c52:	8db6                	mv	s11,a3
    7c54:	000d1463          	bnez	s10,7c5c <_vsnprintf+0x534c>
    7c58:	e1dfd06f          	j	5a74 <_vsnprintf+0x3164>
    7c5c:	e2ffd06f          	j	5a8a <_vsnprintf+0x317a>
    7c60:	8d46                	mv	s10,a7
    7c62:	8a9a                	mv	s5,t1
    7c64:	bc8fc06f          	j	402c <_vsnprintf+0x171c>
    7c68:	00a77463          	bgeu	a4,a0,7c70 <_vsnprintf+0x5360>
    7c6c:	f1dfe06f          	j	6b88 <_vsnprintf+0x4278>
    7c70:	000e9463          	bnez	t4,7c78 <_vsnprintf+0x5368>
    7c74:	05c0106f          	j	8cd0 <_vsnprintf+0x63c0>
    7c78:	da0b86e3          	beqz	s7,7a24 <_vsnprintf+0x5114>
    7c7c:	4d41                	li	s10,16
    7c7e:	7ba68963          	beq	a3,s10,8430 <_vsnprintf+0x5b20>
    7c82:	4e89                	li	t4,2
    7c84:	01d69463          	bne	a3,t4,7c8c <_vsnprintf+0x537c>
    7c88:	0560106f          	j	8cde <_vsnprintf+0x63ce>
    7c8c:	02000693          	li	a3,32
    7c90:	4d01                	li	s10,0
    7c92:	a4d703e3          	beq	a4,a3,76d8 <_vsnprintf+0x4dc8>
    7c96:	002707b3          	add	a5,a4,sp
    7c9a:	03000b93          	li	s7,48
    7c9e:	00170f13          	addi	t5,a4,1
    7ca2:	03778823          	sb	s7,48(a5)
    7ca6:	02000f93          	li	t6,32
    7caa:	cdff08e3          	beq	t5,t6,797a <_vsnprintf+0x506a>
    7cae:	877a                	mv	a4,t5
    7cb0:	ab55                	j	8264 <_vsnprintf+0x5954>
    7cb2:	0001                	nop
    7cb4:	4b81                	li	s7,0
    7cb6:	47c1                	li	a5,16
    7cb8:	d26fd06f          	j	51de <_vsnprintf+0x28ce>
    7cbc:	4a0e4263          	bltz	t3,8160 <_vsnprintf+0x5850>
    7cc0:	0042fe13          	andi	t3,t0,4
    7cc4:	660e05e3          	beqz	t3,8b2e <_vsnprintf+0x621e>
    7cc8:	02078593          	addi	a1,a5,32
    7ccc:	03010c93          	addi	s9,sp,48
    7cd0:	00178d13          	addi	s10,a5,1
    7cd4:	01958db3          	add	s11,a1,s9
    7cd8:	02b00693          	li	a3,43
    7cdc:	fedd8023          	sb	a3,-32(s11)
    7ce0:	6382                	ld	t2,0(sp)
    7ce2:	8dc2                	mv	s11,a6
    7ce4:	8536                	mv	a0,a3
    7ce6:	4b09                	li	s6,2
    7ce8:	9ccfc06f          	j	3eb4 <_vsnprintf+0x15a4>
    7cec:	040d0b63          	beqz	s10,7d42 <_vsnprintf+0x5432>
    7cf0:	3c0b85e3          	beqz	s7,88ba <_vsnprintf+0x5faa>
    7cf4:	4bc1                	li	s7,16
    7cf6:	3b768fe3          	beq	a3,s7,88b4 <_vsnprintf+0x5fa4>
    7cfa:	4509                	li	a0,2
    7cfc:	4d01                	li	s10,0
    7cfe:	d8a696e3          	bne	a3,a0,7a8a <_vsnprintf+0x517a>
    7d02:	bb41                	j	7a92 <_vsnprintf+0x5182>
    7d04:	ffed8313          	addi	t1,s11,-2
    7d08:	02030c93          	addi	s9,t1,32
    7d0c:	03010e13          	addi	t3,sp,48
    7d10:	02067e93          	andi	t4,a2,32
    7d14:	1dfd                	addi	s11,s11,-1
    7d16:	01cc82b3          	add	t0,s9,t3
    7d1a:	4c0e96e3          	bnez	t4,89e6 <_vsnprintf+0x60d6>
    7d1e:	07800d13          	li	s10,120
    7d22:	ffa28023          	sb	s10,-32(t0)
    7d26:	8d5e                	mv	s10,s7
    7d28:	002d8eb3          	add	t4,s11,sp
    7d2c:	03000c93          	li	s9,48
    7d30:	001d8793          	addi	a5,s11,1
    7d34:	039e8823          	sb	s9,48(t4)
    7d38:	02000e13          	li	t3,32
    7d3c:	8dbe                	mv	s11,a5
    7d3e:	09c79263          	bne	a5,t3,7dc2 <_vsnprintf+0x54b2>
    7d42:	00367593          	andi	a1,a2,3
    7d46:	c199                	beqz	a1,7d4c <_vsnprintf+0x543c>
    7d48:	bbbfd06f          	j	5902 <_vsnprintf+0x2ff2>
    7d4c:	02000d93          	li	s11,32
    7d50:	7c08bc0b          	th.extu	s8,a7,31,0
    7d54:	d51deee3          	bltu	s11,a7,7ab0 <_vsnprintf+0x51a0>
    7d58:	babfd06f          	j	5902 <_vsnprintf+0x2ff2>
    7d5c:	040d0f63          	beqz	s10,7dba <_vsnprintf+0x54aa>
    7d60:	4d01                	li	s10,0
    7d62:	d00b9ee3          	bnez	s7,7a7e <_vsnprintf+0x516e>
    7d66:	00ad8663          	beq	s11,a0,7d72 <_vsnprintf+0x5462>
    7d6a:	7c08bc0b          	th.extu	s8,a7,31,0
    7d6e:	d18d98e3          	bne	s11,s8,7a7e <_vsnprintf+0x516e>
    7d72:	fffd8e13          	addi	t3,s11,-1
    7d76:	8bea                	mv	s7,s10
    7d78:	020e1463          	bnez	t3,7da0 <_vsnprintf+0x5490>
    7d7c:	4dc1                	li	s11,16
    7d7e:	3fb685e3          	beq	a3,s11,8968 <_vsnprintf+0x6058>
    7d82:	4b89                	li	s7,2
    7d84:	597685e3          	beq	a3,s7,8b0e <_vsnprintf+0x61fe>
    7d88:	03000513          	li	a0,48
    7d8c:	02a10823          	sb	a0,48(sp)
    7d90:	8a0d                	andi	a2,a2,3
    7d92:	560604e3          	beqz	a2,8afa <_vsnprintf+0x61ea>
    7d96:	6682                	ld	a3,0(sp)
    7d98:	4d85                	li	s11,1
    7d9a:	b6ffd06f          	j	5908 <_vsnprintf+0x2ff8>
    7d9e:	4e7d                	li	t3,31
    7da0:	4b41                	li	s6,16
    7da2:	f76681e3          	beq	a3,s6,7d04 <_vsnprintf+0x53f4>
    7da6:	4709                	li	a4,2
    7da8:	40e68de3          	beq	a3,a4,89c2 <_vsnprintf+0x60b2>
    7dac:	002e0f33          	add	t5,t3,sp
    7db0:	03000793          	li	a5,48
    7db4:	02ff0823          	sb	a5,48(t5)
    7db8:	8d5e                	mv	s10,s7
    7dba:	02000393          	li	t2,32
    7dbe:	f87d82e3          	beq	s11,t2,7d42 <_vsnprintf+0x5432>
    7dc2:	00367293          	andi	t0,a2,3
    7dc6:	00029663          	bnez	t0,7dd2 <_vsnprintf+0x54c2>
    7dca:	7c08bc0b          	th.extu	s8,a7,31,0
    7dce:	cf8de1e3          	bltu	s11,s8,7ab0 <_vsnprintf+0x51a0>
    7dd2:	6682                	ld	a3,0(sp)
    7dd4:	b35fd06f          	j	5908 <_vsnprintf+0x2ff8>
    7dd8:	4e0edc63          	bgez	t4,82d0 <_vsnprintf+0x59c0>
    7ddc:	7c0c3c0b          	th.extu	s8,s8,31,0
    7de0:	38fd                	addiw	a7,a7,-1
    7de2:	0187f463          	bgeu	a5,s8,7dea <_vsnprintf+0x54da>
    7de6:	e33fd06f          	j	5c18 <_vsnprintf+0x3308>
    7dea:	7c08b68b          	th.extu	a3,a7,31,0
    7dee:	00d7f463          	bgeu	a5,a3,7df6 <_vsnprintf+0x54e6>
    7df2:	f25fd06f          	j	5d16 <_vsnprintf+0x3406>
    7df6:	02000293          	li	t0,32
    7dfa:	00579463          	bne	a5,t0,7e02 <_vsnprintf+0x54f2>
    7dfe:	9a0fe06f          	j	5f9e <_vsnprintf+0x368e>
    7e02:	86be                	mv	a3,a5
    7e04:	810fe06f          	j	5e14 <_vsnprintf+0x3504>
    7e08:	7c0c3d0b          	th.extu	s10,s8,31,0
    7e0c:	65a7f8e3          	bgeu	a5,s10,8c5c <_vsnprintf+0x634c>
    7e10:	0015fd93          	andi	s11,a1,1
    7e14:	4881                	li	a7,0
    7e16:	824fd06f          	j	4e3a <_vsnprintf+0x252a>
    7e1a:	560d1463          	bnez	s10,8382 <_vsnprintf+0x5a72>
    7e1e:	02000c13          	li	s8,32
    7e22:	c58d8363          	beq	s11,s8,7268 <_vsnprintf+0x4958>
    7e26:	8a0d                	andi	a2,a2,3
    7e28:	f64d                	bnez	a2,7dd2 <_vsnprintf+0x54c2>
    7e2a:	8c2a                	mv	s8,a0
    7e2c:	c8ade2e3          	bltu	s11,a0,7ab0 <_vsnprintf+0x51a0>
    7e30:	6682                	ld	a3,0(sp)
    7e32:	ad7fd06f          	j	5908 <_vsnprintf+0x2ff8>
    7e36:	0001                	nop
    7e38:	3e088463          	beqz	a7,8220 <_vsnprintf+0x5910>
    7e3c:	001f7b13          	andi	s6,t5,1
    7e40:	7c0c350b          	th.extu	a0,s8,31,0
    7e44:	03010813          	addi	a6,sp,48
    7e48:	6a0b0063          	beqz	s6,84e8 <_vsnprintf+0x5bd8>
    7e4c:	7c08b78b          	th.extu	a5,a7,31,0
    7e50:	c119                	beqz	a0,7e56 <_vsnprintf+0x5546>
    7e52:	d37fe06f          	j	6b88 <_vsnprintf+0x4278>
    7e56:	e29fe06f          	j	6c7e <_vsnprintf+0x436e>
    7e5a:	0001                	nop
    7e5c:	7c0c3c0b          	th.extu	s8,s8,31,0
    7e60:	0187f463          	bgeu	a5,s8,7e68 <_vsnprintf+0x5558>
    7e64:	c42fe06f          	j	62a6 <_vsnprintf+0x3996>
    7e68:	02000513          	li	a0,32
    7e6c:	9aa78763          	beq	a5,a0,701a <_vsnprintf+0x470a>
    7e70:	060e5863          	bgez	t3,7ee0 <_vsnprintf+0x55d0>
    7e74:	00a78633          	add	a2,a5,a0
    7e78:	03010c93          	addi	s9,sp,48
    7e7c:	01960733          	add	a4,a2,s9
    7e80:	02d00a93          	li	s5,45
    7e84:	00178c13          	addi	s8,a5,1
    7e88:	ff570023          	sb	s5,-32(a4)
    7e8c:	e20fe06f          	j	64ac <_vsnprintf+0x3b9c>
    7e90:	002783b3          	add	t2,a5,sp
    7e94:	02d00513          	li	a0,45
    7e98:	02a38823          	sb	a0,48(t2)
    7e9c:	6302                	ld	t1,0(sp)
    7e9e:	00178c13          	addi	s8,a5,1
    7ea2:	4b09                	li	s6,2
    7ea4:	af3fc06f          	j	4996 <_vsnprintf+0x2086>
    7ea8:	004af593          	andi	a1,s5,4
    7eac:	02b00513          	li	a0,43
    7eb0:	e599                	bnez	a1,7ebe <_vsnprintf+0x55ae>
    7eb2:	008afc93          	andi	s9,s5,8
    7eb6:	780c8263          	beqz	s9,863a <_vsnprintf+0x5d2a>
    7eba:	02000513          	li	a0,32
    7ebe:	8dc2                	mv	s11,a6
    7ec0:	02a10823          	sb	a0,48(sp)
    7ec4:	6802                	ld	a6,0(sp)
    7ec6:	4c05                	li	s8,1
    7ec8:	4b09                	li	s6,2
    7eca:	03010c93          	addi	s9,sp,48
    7ece:	8dcfe06f          	j	5faa <_vsnprintf+0x369a>
    7ed2:	7c0c3c0b          	th.extu	s8,s8,31,0
    7ed6:	4781                	li	a5,0
    7ed8:	03010b93          	addi	s7,sp,48
    7edc:	980c1363          	bnez	s8,7062 <_vsnprintf+0x4752>
    7ee0:	0045fb13          	andi	s6,a1,4
    7ee4:	8bae                	mv	s7,a1
    7ee6:	100b07e3          	beqz	s6,87f4 <_vsnprintf+0x5ee4>
    7eea:	02078393          	addi	t2,a5,32
    7eee:	03010f13          	addi	t5,sp,48
    7ef2:	01e38b33          	add	s6,t2,t5
    7ef6:	02b00513          	li	a0,43
    7efa:	feab0023          	sb	a0,-32(s6)
    7efe:	0035f313          	andi	t1,a1,3
    7f02:	00178c13          	addi	s8,a5,1
    7f06:	00031463          	bnez	t1,7f0e <_vsnprintf+0x55fe>
    7f0a:	f49fe06f          	j	6e52 <_vsnprintf+0x4542>
    7f0e:	6302                	ld	t1,0(sp)
    7f10:	4b01                	li	s6,0
    7f12:	8bfa                	mv	s7,t5
    7f14:	a83fc06f          	j	4996 <_vsnprintf+0x2086>
    7f18:	4d01                	li	s10,0
    7f1a:	02067c93          	andi	s9,a2,32
    7f1e:	7c0c8163          	beqz	s9,86e0 <_vsnprintf+0x5dd0>
    7f22:	02000e13          	li	t3,32
    7f26:	b7cd86e3          	beq	s11,t3,7a92 <_vsnprintf+0x5182>
    7f2a:	020d8293          	addi	t0,s11,32
    7f2e:	180c                	addi	a1,sp,48
    7f30:	00b28bb3          	add	s7,t0,a1
    7f34:	05800513          	li	a0,88
    7f38:	feab8023          	sb	a0,-32(s7)
    7f3c:	0d85                	addi	s11,s11,1
    7f3e:	b6b1                	j	7a8a <_vsnprintf+0x517a>
    7f40:	86be                	mv	a3,a5
    7f42:	ebffd06f          	j	5e00 <_vsnprintf+0x34f0>
    7f46:	e119                	bnez	a0,7f4c <_vsnprintf+0x563c>
    7f48:	aa0fc06f          	j	41e8 <_vsnprintf+0x18d8>
    7f4c:	6c82                	ld	s9,0(sp)
    7f4e:	2b85                	addiw	s7,s7,1
    7f50:	4a81                	li	s5,0
    7f52:	f81fa06f          	j	2ed2 <_vsnprintf+0x5c2>
    7f56:	b00b89e3          	beqz	s7,7a68 <_vsnprintf+0x5158>
    7f5a:	4c41                	li	s8,16
    7f5c:	f7868963          	beq	a3,s8,76ce <_vsnprintf+0x4dbe>
    7f60:	4589                	li	a1,2
    7f62:	f6b69263          	bne	a3,a1,76c6 <_vsnprintf+0x4db6>
    7f66:	f68ff06f          	j	76ce <_vsnprintf+0x4dbe>
    7f6a:	000b8463          	beqz	s7,7f72 <_vsnprintf+0x5662>
    7f6e:	9fafd06f          	j	5168 <_vsnprintf+0x2858>
    7f72:	0045f293          	andi	t0,a1,4
    7f76:	00028463          	beqz	t0,7f7e <_vsnprintf+0x566e>
    7f7a:	e37fc06f          	j	4db0 <_vsnprintf+0x24a0>
    7f7e:	0085fb93          	andi	s7,a1,8
    7f82:	000b8463          	beqz	s7,7f8a <_vsnprintf+0x567a>
    7f86:	a56fd06f          	j	51dc <_vsnprintf+0x28cc>
    7f8a:	8d3e                	mv	s10,a5
    7f8c:	180c                	addi	a1,sp,48
    7f8e:	02078793          	addi	a5,a5,32
    7f92:	00b78fb3          	add	t6,a5,a1
    7f96:	fdffc503          	lbu	a0,-33(t6)
    7f9a:	e72fc06f          	j	460c <_vsnprintf+0x1cfc>
    7f9e:	680e9563          	bnez	t4,8628 <_vsnprintf+0x5d18>
    7fa2:	4b81                	li	s7,0
    7fa4:	00367713          	andi	a4,a2,3
    7fa8:	5a071e63          	bnez	a4,8564 <_vsnprintf+0x5c54>
    7fac:	02000d13          	li	s10,32
    7fb0:	7c08bc0b          	th.extu	s8,a7,31,0
    7fb4:	5b1d7863          	bgeu	s10,a7,8564 <_vsnprintf+0x5c54>
    7fb8:	6602                	ld	a2,0(sp)
    7fba:	ec46                	sd	a7,24(sp)
    7fbc:	86a6                	mv	a3,s1
    7fbe:	40cd0b33          	sub	s6,s10,a2
    7fc2:	fffb4e93          	not	t4,s6
    7fc6:	018e8833          	add	a6,t4,s8
    7fca:	85ca                	mv	a1,s2
    7fcc:	02000513          	li	a0,32
    7fd0:	40c80cb3          	sub	s9,a6,a2
    7fd4:	00160d93          	addi	s11,a2,1
    7fd8:	9402                	jalr	s0
    7fda:	01bb0333          	add	t1,s6,s11
    7fde:	68e2                	ld	a7,24(sp)
    7fe0:	007cfc93          	andi	s9,s9,7
    7fe4:	15837363          	bgeu	t1,s8,812a <_vsnprintf+0x581a>
    7fe8:	0a0c8863          	beqz	s9,8098 <_vsnprintf+0x5788>
    7fec:	4685                	li	a3,1
    7fee:	08dc8863          	beq	s9,a3,807e <_vsnprintf+0x576e>
    7ff2:	4e09                	li	t3,2
    7ff4:	07cc8c63          	beq	s9,t3,806c <_vsnprintf+0x575c>
    7ff8:	428d                	li	t0,3
    7ffa:	065c8063          	beq	s9,t0,805a <_vsnprintf+0x574a>
    7ffe:	4f91                	li	t6,4
    8000:	05fc8463          	beq	s9,t6,8048 <_vsnprintf+0x5738>
    8004:	4f15                	li	t5,5
    8006:	03ec8863          	beq	s9,t5,8036 <_vsnprintf+0x5726>
    800a:	4519                	li	a0,6
    800c:	00ac8c63          	beq	s9,a0,8024 <_vsnprintf+0x5714>
    8010:	866e                	mv	a2,s11
    8012:	ec46                	sd	a7,24(sp)
    8014:	86a6                	mv	a3,s1
    8016:	85ca                	mv	a1,s2
    8018:	02000513          	li	a0,32
    801c:	6d82                	ld	s11,0(sp)
    801e:	9402                	jalr	s0
    8020:	68e2                	ld	a7,24(sp)
    8022:	0d89                	addi	s11,s11,2
    8024:	866e                	mv	a2,s11
    8026:	ec46                	sd	a7,24(sp)
    8028:	86a6                	mv	a3,s1
    802a:	85ca                	mv	a1,s2
    802c:	02000513          	li	a0,32
    8030:	9402                	jalr	s0
    8032:	68e2                	ld	a7,24(sp)
    8034:	0d85                	addi	s11,s11,1
    8036:	866e                	mv	a2,s11
    8038:	ec46                	sd	a7,24(sp)
    803a:	86a6                	mv	a3,s1
    803c:	85ca                	mv	a1,s2
    803e:	02000513          	li	a0,32
    8042:	9402                	jalr	s0
    8044:	68e2                	ld	a7,24(sp)
    8046:	0d85                	addi	s11,s11,1
    8048:	866e                	mv	a2,s11
    804a:	ec46                	sd	a7,24(sp)
    804c:	86a6                	mv	a3,s1
    804e:	85ca                	mv	a1,s2
    8050:	02000513          	li	a0,32
    8054:	9402                	jalr	s0
    8056:	68e2                	ld	a7,24(sp)
    8058:	0d85                	addi	s11,s11,1
    805a:	866e                	mv	a2,s11
    805c:	ec46                	sd	a7,24(sp)
    805e:	86a6                	mv	a3,s1
    8060:	85ca                	mv	a1,s2
    8062:	02000513          	li	a0,32
    8066:	9402                	jalr	s0
    8068:	68e2                	ld	a7,24(sp)
    806a:	0d85                	addi	s11,s11,1
    806c:	866e                	mv	a2,s11
    806e:	ec46                	sd	a7,24(sp)
    8070:	86a6                	mv	a3,s1
    8072:	85ca                	mv	a1,s2
    8074:	02000513          	li	a0,32
    8078:	9402                	jalr	s0
    807a:	68e2                	ld	a7,24(sp)
    807c:	0d85                	addi	s11,s11,1
    807e:	866e                	mv	a2,s11
    8080:	ec46                	sd	a7,24(sp)
    8082:	86a6                	mv	a3,s1
    8084:	85ca                	mv	a1,s2
    8086:	02000513          	li	a0,32
    808a:	9402                	jalr	s0
    808c:	0d85                	addi	s11,s11,1
    808e:	01bb07b3          	add	a5,s6,s11
    8092:	68e2                	ld	a7,24(sp)
    8094:	0987fb63          	bgeu	a5,s8,812a <_vsnprintf+0x581a>
    8098:	ec56                	sd	s5,24(sp)
    809a:	f05e                	sd	s7,32(sp)
    809c:	8bc6                	mv	s7,a7
    809e:	866e                	mv	a2,s11
    80a0:	86a6                	mv	a3,s1
    80a2:	85ca                	mv	a1,s2
    80a4:	02000513          	li	a0,32
    80a8:	9402                	jalr	s0
    80aa:	001d8c93          	addi	s9,s11,1
    80ae:	8666                	mv	a2,s9
    80b0:	86a6                	mv	a3,s1
    80b2:	85ca                	mv	a1,s2
    80b4:	02000513          	li	a0,32
    80b8:	9402                	jalr	s0
    80ba:	002d8a93          	addi	s5,s11,2
    80be:	8656                	mv	a2,s5
    80c0:	86a6                	mv	a3,s1
    80c2:	85ca                	mv	a1,s2
    80c4:	02000513          	li	a0,32
    80c8:	9402                	jalr	s0
    80ca:	003d8c93          	addi	s9,s11,3
    80ce:	8666                	mv	a2,s9
    80d0:	86a6                	mv	a3,s1
    80d2:	85ca                	mv	a1,s2
    80d4:	02000513          	li	a0,32
    80d8:	9402                	jalr	s0
    80da:	004d8a93          	addi	s5,s11,4
    80de:	8656                	mv	a2,s5
    80e0:	86a6                	mv	a3,s1
    80e2:	85ca                	mv	a1,s2
    80e4:	02000513          	li	a0,32
    80e8:	9402                	jalr	s0
    80ea:	005d8c93          	addi	s9,s11,5
    80ee:	8666                	mv	a2,s9
    80f0:	86a6                	mv	a3,s1
    80f2:	85ca                	mv	a1,s2
    80f4:	02000513          	li	a0,32
    80f8:	9402                	jalr	s0
    80fa:	006d8a93          	addi	s5,s11,6
    80fe:	86a6                	mv	a3,s1
    8100:	8656                	mv	a2,s5
    8102:	85ca                	mv	a1,s2
    8104:	02000513          	li	a0,32
    8108:	9402                	jalr	s0
    810a:	007d8c93          	addi	s9,s11,7
    810e:	86a6                	mv	a3,s1
    8110:	8666                	mv	a2,s9
    8112:	85ca                	mv	a1,s2
    8114:	02000513          	li	a0,32
    8118:	0da1                	addi	s11,s11,8
    811a:	9402                	jalr	s0
    811c:	01bb08b3          	add	a7,s6,s11
    8120:	f788efe3          	bltu	a7,s8,809e <_vsnprintf+0x578e>
    8124:	88de                	mv	a7,s7
    8126:	6ae2                	ld	s5,24(sp)
    8128:	7b82                	ld	s7,32(sp)
    812a:	6602                	ld	a2,0(sp)
    812c:	fffc0393          	addi	t2,s8,-1
    8130:	001d0593          	addi	a1,s10,1
    8134:	41a387b3          	sub	a5,t2,s10
    8138:	00bc3733          	sltu	a4,s8,a1
    813c:	42e0178b          	th.mvnez	a5,zero,a4
    8140:	00160e93          	addi	t4,a2,1
    8144:	03010b13          	addi	s6,sp,48
    8148:	01d783b3          	add	t2,a5,t4
    814c:	000d0463          	beqz	s10,8154 <_vsnprintf+0x5844>
    8150:	d5cfe06f          	j	66ac <_vsnprintf+0x3d9c>
    8154:	000b9463          	bnez	s7,815c <_vsnprintf+0x584c>
    8158:	ea6fe06f          	j	67fe <_vsnprintf+0x3eee>
    815c:	eb8fe06f          	j	6814 <_vsnprintf+0x3f04>
    8160:	02078b93          	addi	s7,a5,32
    8164:	03010f93          	addi	t6,sp,48
    8168:	00178d13          	addi	s10,a5,1
    816c:	01fb8db3          	add	s11,s7,t6
    8170:	02d00693          	li	a3,45
    8174:	b6a5                	j	7cdc <_vsnprintf+0x53cc>
    8176:	000b9463          	bnez	s7,817e <_vsnprintf+0x586e>
    817a:	c8afc06f          	j	4604 <_vsnprintf+0x1cf4>
    817e:	4b81                	li	s7,0
    8180:	000c8463          	beqz	s9,8188 <_vsnprintf+0x5878>
    8184:	c80fc06f          	j	4604 <_vsnprintf+0x1cf4>
    8188:	4b81                	li	s7,0
    818a:	01af8463          	beq	t6,s10,8192 <_vsnprintf+0x5882>
    818e:	cc4fe06f          	j	6652 <_vsnprintf+0x3d42>
    8192:	fffd0793          	addi	a5,s10,-1
    8196:	4b81                	li	s7,0
    8198:	020d0f13          	addi	t5,s10,32
    819c:	03010893          	addi	a7,sp,48
    81a0:	05800313          	li	t1,88
    81a4:	011f0533          	add	a0,t5,a7
    81a8:	fc650f23          	sb	t1,-34(a0)
    81ac:	ff1fc06f          	j	519c <_vsnprintf+0x288c>
    81b0:	36088a63          	beqz	a7,8524 <_vsnprintf+0x5c14>
    81b4:	001ffb13          	andi	s6,t6,1
    81b8:	7c0c350b          	th.extu	a0,s8,31,0
    81bc:	03010813          	addi	a6,sp,48
    81c0:	340b0263          	beqz	s6,8504 <_vsnprintf+0x5bf4>
    81c4:	c119                	beqz	a0,81ca <_vsnprintf+0x58ba>
    81c6:	ebffe06f          	j	7084 <_vsnprintf+0x4774>
    81ca:	7c08b50b          	th.extu	a0,a7,31,0
    81ce:	fa9fe06f          	j	7176 <_vsnprintf+0x4866>
    81d2:	0001                	nop
    81d4:	ac0c1163          	bnez	s8,7496 <_vsnprintf+0x4b86>
    81d8:	0045fb13          	andi	s6,a1,4
    81dc:	8cae                	mv	s9,a1
    81de:	020b01e3          	beqz	s6,8a00 <_vsnprintf+0x60f0>
    81e2:	02078d93          	addi	s11,a5,32
    81e6:	03010293          	addi	t0,sp,48
    81ea:	005d8b33          	add	s6,s11,t0
    81ee:	02b00513          	li	a0,43
    81f2:	feab0023          	sb	a0,-32(s6)
    81f6:	0035f313          	andi	t1,a1,3
    81fa:	00178c13          	addi	s8,a5,1
    81fe:	7e031b63          	bnez	t1,89f4 <_vsnprintf+0x60e4>
    8202:	7c08bb8b          	th.extu	s7,a7,31,0
    8206:	8dc2                	mv	s11,a6
    8208:	4b01                	li	s6,0
    820a:	017c7463          	bgeu	s8,s7,8212 <_vsnprintf+0x5902>
    820e:	fb6fe06f          	j	69c4 <_vsnprintf+0x40b4>
    8212:	6802                	ld	a6,0(sp)
    8214:	02b00513          	li	a0,43
    8218:	03010c93          	addi	s9,sp,48
    821c:	d8ffd06f          	j	5faa <_vsnprintf+0x369a>
    8220:	7c0c350b          	th.extu	a0,s8,31,0
    8224:	03010813          	addi	a6,sp,48
    8228:	ea051963          	bnez	a0,78da <_vsnprintf+0x4fca>
    822c:	003f7693          	andi	a3,t5,3
    8230:	6e02                	ld	t3,0(sp)
    8232:	e299                	bnez	a3,8238 <_vsnprintf+0x5928>
    8234:	f99fb06f          	j	41cc <_vsnprintf+0x18bc>
    8238:	6e02                	ld	t3,0(sp)
    823a:	e072                	sd	t3,0(sp)
    823c:	fadfb06f          	j	41e8 <_vsnprintf+0x18d8>
    8240:	00278bb3          	add	s7,a5,sp
    8244:	02d00513          	li	a0,45
    8248:	02ab8823          	sb	a0,48(s7)
    824c:	8dc2                	mv	s11,a6
    824e:	00178c13          	addi	s8,a5,1
    8252:	6802                	ld	a6,0(sp)
    8254:	4b09                	li	s6,2
    8256:	d55fd06f          	j	5faa <_vsnprintf+0x369a>
    825a:	4d01                	li	s10,0
    825c:	02000b93          	li	s7,32
    8260:	f1770d63          	beq	a4,s7,797a <_vsnprintf+0x506a>
    8264:	003e7593          	andi	a1,t3,3
    8268:	c199                	beqz	a1,826e <_vsnprintf+0x595e>
    826a:	b19fe06f          	j	6d82 <_vsnprintf+0x4472>
    826e:	7c08bc0b          	th.extu	s8,a7,31,0
    8272:	c7876b63          	bltu	a4,s8,76e8 <_vsnprintf+0x4dd8>
    8276:	6e02                	ld	t3,0(sp)
    8278:	946fd06f          	j	53be <_vsnprintf+0x2aae>
    827c:	00857693          	andi	a3,a0,8
    8280:	4b89                	li	s7,2
    8282:	38069f63          	bnez	a3,8620 <_vsnprintf+0x5d10>
    8286:	05210f93          	addi	t6,sp,82
    828a:	8d5e                	mv	s10,s7
    828c:	4ac1                	li	s5,16
    828e:	fdffc503          	lbu	a0,-33(t6)
    8292:	b7afc06f          	j	460c <_vsnprintf+0x1cfc>
    8296:	6682                	ld	a3,0(sp)
    8298:	4d09                	li	s10,2
    829a:	e6efd06f          	j	5908 <_vsnprintf+0x2ff8>
    829e:	7c0c3d0b          	th.extu	s10,s8,31,0
    82a2:	01a7f463          	bgeu	a5,s10,82aa <_vsnprintf+0x599a>
    82a6:	b95fc06f          	j	4e3a <_vsnprintf+0x252a>
    82aa:	02000f13          	li	t5,32
    82ae:	93e78863          	beq	a5,t5,73de <_vsnprintf+0x4ace>
    82b2:	1e0e5063          	bgez	t3,8492 <_vsnprintf+0x5b82>
    82b6:	01e78ab3          	add	s5,a5,t5
    82ba:	1810                	addi	a2,sp,48
    82bc:	00178d13          	addi	s10,a5,1
    82c0:	02d00713          	li	a4,45
    82c4:	00ca87b3          	add	a5,s5,a2
    82c8:	fee78023          	sb	a4,-32(a5)
    82cc:	c99fc06f          	j	4f64 <_vsnprintf+0x2654>
    82d0:	00c6ff13          	andi	t5,a3,12
    82d4:	7c0c3c0b          	th.extu	s8,s8,31,0
    82d8:	fff8869b          	addiw	a3,a7,-1
    82dc:	43e6988b          	th.mvnez	a7,a3,t5
    82e0:	0187f463          	bgeu	a5,s8,82e8 <_vsnprintf+0x59d8>
    82e4:	935fd06f          	j	5c18 <_vsnprintf+0x3308>
    82e8:	7c08b68b          	th.extu	a3,a7,31,0
    82ec:	00d7f463          	bgeu	a5,a3,82f4 <_vsnprintf+0x59e4>
    82f0:	a27fd06f          	j	5d16 <_vsnprintf+0x3406>
    82f4:	02000e93          	li	t4,32
    82f8:	01d79463          	bne	a5,t4,8300 <_vsnprintf+0x59f0>
    82fc:	ca3fd06f          	j	5f9e <_vsnprintf+0x368e>
    8300:	bde1                	j	81d8 <_vsnprintf+0x58c8>
    8302:	0001                	nop
    8304:	6e02                	ld	t3,0(sp)
    8306:	4d09                	li	s10,2
    8308:	8b6fd06f          	j	53be <_vsnprintf+0x2aae>
    830c:	4781                	li	a5,0
    830e:	00c5fb93          	andi	s7,a1,12
    8312:	fff8829b          	addiw	t0,a7,-1
    8316:	7c0c3c0b          	th.extu	s8,s8,31,0
    831a:	4372988b          	th.mvnez	a7,t0,s7
    831e:	4f85                	li	t6,1
    8320:	03010b93          	addi	s7,sp,48
    8324:	0187f463          	bgeu	a5,s8,832c <_vsnprintf+0x5a1c>
    8328:	f7ffd06f          	j	62a6 <_vsnprintf+0x3996>
    832c:	7c08bf8b          	th.extu	t6,a7,31,0
    8330:	01f7f463          	bgeu	a5,t6,8338 <_vsnprintf+0x5a28>
    8334:	868fe06f          	j	639c <_vsnprintf+0x3a8c>
    8338:	02000c13          	li	s8,32
    833c:	01879463          	bne	a5,s8,8344 <_vsnprintf+0x5a34>
    8340:	d0dfe06f          	j	704c <_vsnprintf+0x473c>
    8344:	be71                	j	7ee0 <_vsnprintf+0x55d0>
    8346:	0001                	nop
    8348:	4809                	li	a6,2
    834a:	400b8763          	beqz	s7,8758 <_vsnprintf+0x5e48>
    834e:	4cc1                	li	s9,16
    8350:	3d968363          	beq	a3,s9,8716 <_vsnprintf+0x5e06>
    8354:	4309                	li	t1,2
    8356:	3e668563          	beq	a3,t1,8740 <_vsnprintf+0x5e30>
    835a:	02000e93          	li	t4,32
    835e:	25dd1863          	bne	s10,t4,85ae <_vsnprintf+0x5c9e>
    8362:	00367d13          	andi	s10,a2,3
    8366:	000d0463          	beqz	s10,836e <_vsnprintf+0x5a5e>
    836a:	b3afe06f          	j	66a4 <_vsnprintf+0x3d94>
    836e:	02000d13          	li	s10,32
    8372:	011d6463          	bltu	s10,a7,837a <_vsnprintf+0x5a6a>
    8376:	b2efe06f          	j	66a4 <_vsnprintf+0x3d94>
    837a:	7c08bc0b          	th.extu	s8,a7,31,0
    837e:	8bc2                	mv	s7,a6
    8380:	b925                	j	7fb8 <_vsnprintf+0x56a8>
    8382:	4d01                	li	s10,0
    8384:	ef2ff06f          	j	7a76 <_vsnprintf+0x5166>
    8388:	26088a63          	beqz	a7,85fc <_vsnprintf+0x5cec>
    838c:	001ffc93          	andi	s9,t6,1
    8390:	7c0c370b          	th.extu	a4,s8,31,0
    8394:	03010b13          	addi	s6,sp,48
    8398:	4a0c8e63          	beqz	s9,8854 <_vsnprintf+0x5f44>
    839c:	7c08b78b          	th.extu	a5,a7,31,0
    83a0:	90071c63          	bnez	a4,74b8 <_vsnprintf+0x4ba8>
    83a4:	a0aff06f          	j	75ae <_vsnprintf+0x4c9e>
    83a8:	00adf463          	bgeu	s11,a0,83b0 <_vsnprintf+0x5aa0>
    83ac:	cd9fe06f          	j	7084 <_vsnprintf+0x4774>
    83b0:	560d0b63          	beqz	s10,8926 <_vsnprintf+0x6016>
    83b4:	540b9c63          	bnez	s7,890c <_vsnprintf+0x5ffc>
    83b8:	4d01                	li	s10,0
    83ba:	b275                	j	7d66 <_vsnprintf+0x5456>
    83bc:	8bea                	mv	s7,s10
    83be:	7c0c350b          	th.extu	a0,s8,31,0
    83c2:	e62ff06f          	j	7a24 <_vsnprintf+0x5114>
    83c6:	1a0e8263          	beqz	t4,856a <_vsnprintf+0x5c5a>
    83ca:	040b9263          	bnez	s7,840e <_vsnprintf+0x5afe>
    83ce:	01a70763          	beq	a4,s10,83dc <_vsnprintf+0x5acc>
    83d2:	7c08be8b          	th.extu	t4,a7,31,0
    83d6:	885e                	mv	a6,s7
    83d8:	f7ae9be3          	bne	t4,s10,834e <_vsnprintf+0x5a3e>
    83dc:	fffd0593          	addi	a1,s10,-1
    83e0:	4a059d63          	bnez	a1,889a <_vsnprintf+0x5f8a>
    83e4:	4841                	li	a6,16
    83e6:	4f068963          	beq	a3,a6,88d8 <_vsnprintf+0x5fc8>
    83ea:	4d09                	li	s10,2
    83ec:	51a68463          	beq	a3,s10,88f4 <_vsnprintf+0x5fe4>
    83f0:	03000713          	li	a4,48
    83f4:	02e10823          	sb	a4,48(sp)
    83f8:	8a0d                	andi	a2,a2,3
    83fa:	4c060763          	beqz	a2,88c8 <_vsnprintf+0x5fb8>
    83fe:	6382                	ld	t2,0(sp)
    8400:	4d05                	li	s10,1
    8402:	aaafe06f          	j	66ac <_vsnprintf+0x3d9c>
    8406:	49ac0963          	beq	s8,s10,8898 <_vsnprintf+0x5f88>
    840a:	49a88763          	beq	a7,s10,8898 <_vsnprintf+0x5f88>
    840e:	4801                	li	a6,0
    8410:	bf3d                	j	834e <_vsnprintf+0x5a3e>
    8412:	02000313          	li	t1,32
    8416:	aa670c63          	beq	a4,t1,76ce <_vsnprintf+0x4dbe>
    841a:	00e80633          	add	a2,a6,a4
    841e:	8bea                	mv	s7,s10
    8420:	0705                	addi	a4,a4,1
    8422:	06200f93          	li	t6,98
    8426:	01f60023          	sb	t6,0(a2)
    842a:	8d5e                	mv	s10,s7
    842c:	a9aff06f          	j	76c6 <_vsnprintf+0x4db6>
    8430:	4d01                	li	s10,0
    8432:	020e7c93          	andi	s9,t3,32
    8436:	180c8b63          	beqz	s9,85cc <_vsnprintf+0x5cbc>
    843a:	02000293          	li	t0,32
    843e:	a8570863          	beq	a4,t0,76ce <_vsnprintf+0x4dbe>
    8442:	02070393          	addi	t2,a4,32
    8446:	03010f13          	addi	t5,sp,48
    844a:	01e38bb3          	add	s7,t2,t5
    844e:	05800693          	li	a3,88
    8452:	fedb8023          	sb	a3,-32(s7)
    8456:	0705                	addi	a4,a4,1
    8458:	a6eff06f          	j	76c6 <_vsnprintf+0x4db6>
    845c:	7c0c370b          	th.extu	a4,s8,31,0
    8460:	52ed7363          	bgeu	s10,a4,8986 <_vsnprintf+0x6076>
    8464:	00167c93          	andi	s9,a2,1
    8468:	850ff06f          	j	74b8 <_vsnprintf+0x4ba8>
    846c:	004af313          	andi	t1,s5,4
    8470:	06030663          	beqz	t1,84dc <_vsnprintf+0x5bcc>
    8474:	02b00693          	li	a3,43
    8478:	6382                	ld	t2,0(sp)
    847a:	02d10823          	sb	a3,48(sp)
    847e:	8dc2                	mv	s11,a6
    8480:	8536                	mv	a0,a3
    8482:	4d05                	li	s10,1
    8484:	4b09                	li	s6,2
    8486:	03010313          	addi	t1,sp,48
    848a:	a2bfb06f          	j	3eb4 <_vsnprintf+0x15a4>
    848e:	980d11e3          	bnez	s10,7e10 <_vsnprintf+0x5500>
    8492:	0045fb13          	andi	s6,a1,4
    8496:	832e                	mv	t1,a1
    8498:	5e0b0763          	beqz	s6,8a86 <_vsnprintf+0x6176>
    849c:	02078d93          	addi	s11,a5,32
    84a0:	03010b13          	addi	s6,sp,48
    84a4:	016d8fb3          	add	t6,s11,s6
    84a8:	02b00393          	li	t2,43
    84ac:	fe7f8023          	sb	t2,-32(t6)
    84b0:	0035f713          	andi	a4,a1,3
    84b4:	00178d13          	addi	s10,a5,1
    84b8:	5a071f63          	bnez	a4,8a76 <_vsnprintf+0x6166>
    84bc:	7c08bb8b          	th.extu	s7,a7,31,0
    84c0:	8dc2                	mv	s11,a6
    84c2:	4b01                	li	s6,0
    84c4:	017d7463          	bgeu	s10,s7,84cc <_vsnprintf+0x5bbc>
    84c8:	aadfc06f          	j	4f74 <_vsnprintf+0x2664>
    84cc:	6382                	ld	t2,0(sp)
    84ce:	02b00513          	li	a0,43
    84d2:	03010313          	addi	t1,sp,48
    84d6:	9dffb06f          	j	3eb4 <_vsnprintf+0x15a4>
    84da:	0001                	nop
    84dc:	008af593          	andi	a1,s5,8
    84e0:	cdb5                	beqz	a1,855c <_vsnprintf+0x5c4c>
    84e2:	02000693          	li	a3,32
    84e6:	bf49                	j	8478 <_vsnprintf+0x5b68>
    84e8:	c119                	beqz	a0,84ee <_vsnprintf+0x5bde>
    84ea:	e9efe06f          	j	6b88 <_vsnprintf+0x4278>
    84ee:	7c08bc0b          	th.extu	s8,a7,31,0
    84f2:	9f876b63          	bltu	a4,s8,76e8 <_vsnprintf+0x4dd8>
    84f6:	d40701e3          	beqz	a4,8238 <_vsnprintf+0x5928>
    84fa:	6e02                	ld	t3,0(sp)
    84fc:	03010813          	addi	a6,sp,48
    8500:	ebffc06f          	j	53be <_vsnprintf+0x2aae>
    8504:	c119                	beqz	a0,850a <_vsnprintf+0x5bfa>
    8506:	b7ffe06f          	j	7084 <_vsnprintf+0x4774>
    850a:	7c08bc0b          	th.extu	s8,a7,31,0
    850e:	4d01                	li	s10,0
    8510:	db8de063          	bltu	s11,s8,7ab0 <_vsnprintf+0x51a0>
    8514:	020d8463          	beqz	s11,853c <_vsnprintf+0x5c2c>
    8518:	6682                	ld	a3,0(sp)
    851a:	03010813          	addi	a6,sp,48
    851e:	beafd06f          	j	5908 <_vsnprintf+0x2ff8>
    8522:	0001                	nop
    8524:	7c0c350b          	th.extu	a0,s8,31,0
    8528:	03010813          	addi	a6,sp,48
    852c:	be051863          	bnez	a0,791c <_vsnprintf+0x500c>
    8530:	003ff693          	andi	a3,t6,3
    8534:	6d82                	ld	s11,0(sp)
    8536:	e299                	bnez	a3,853c <_vsnprintf+0x5c2c>
    8538:	d3cfd06f          	j	5a74 <_vsnprintf+0x3164>
    853c:	6d82                	ld	s11,0(sp)
    853e:	e06e                	sd	s11,0(sp)
    8540:	d36fd06f          	j	5a76 <_vsnprintf+0x3166>
    8544:	0086fc93          	andi	s9,a3,8
    8548:	4e0c9363          	bnez	s9,8a2e <_vsnprintf+0x611e>
    854c:	8c3e                	mv	s8,a5
    854e:	4f89                	li	t6,2
    8550:	8dc2                	mv	s11,a6
    8552:	8b7e                	mv	s6,t6
    8554:	6802                	ld	a6,0(sp)
    8556:	e04fe06f          	j	6b5a <_vsnprintf+0x424a>
    855a:	0001                	nop
    855c:	6e02                	ld	t3,0(sp)
    855e:	8dc2                	mv	s11,a6
    8560:	ae9fb06f          	j	4048 <_vsnprintf+0x1738>
    8564:	885e                	mv	a6,s7
    8566:	93efe06f          	j	66a4 <_vsnprintf+0x3d94>
    856a:	4b81                	li	s7,0
    856c:	02000793          	li	a5,32
    8570:	a2fd0ae3          	beq	s10,a5,7fa4 <_vsnprintf+0x5694>
    8574:	8a0d                	andi	a2,a2,3
    8576:	92061c63          	bnez	a2,76ae <_vsnprintf+0x4d9e>
    857a:	7c08bc0b          	th.extu	s8,a7,31,0
    857e:	a38d6de3          	bltu	s10,s8,7fb8 <_vsnprintf+0x56a8>
    8582:	6382                	ld	t2,0(sp)
    8584:	928fe06f          	j	66ac <_vsnprintf+0x3d9c>
    8588:	00ed7463          	bgeu	s10,a4,8590 <_vsnprintf+0x5c80>
    858c:	f2dfe06f          	j	74b8 <_vsnprintf+0x4ba8>
    8590:	420e8c63          	beqz	t4,89c8 <_vsnprintf+0x60b8>
    8594:	e20b8de3          	beqz	s7,83ce <_vsnprintf+0x5abe>
    8598:	4bc1                	li	s7,16
    859a:	17768d63          	beq	a3,s7,8714 <_vsnprintf+0x5e04>
    859e:	4509                	li	a0,2
    85a0:	52a68463          	beq	a3,a0,8ac8 <_vsnprintf+0x61b8>
    85a4:	02000d93          	li	s11,32
    85a8:	4801                	li	a6,0
    85aa:	ddbd02e3          	beq	s10,s11,836e <_vsnprintf+0x5a5e>
    85ae:	002d0bb3          	add	s7,s10,sp
    85b2:	03000393          	li	t2,48
    85b6:	001d0513          	addi	a0,s10,1
    85ba:	027b8823          	sb	t2,48(s7)
    85be:	02000593          	li	a1,32
    85c2:	8bc2                	mv	s7,a6
    85c4:	8d2a                	mv	s10,a0
    85c6:	9cb50fe3          	beq	a0,a1,7fa4 <_vsnprintf+0x5694>
    85ca:	b76d                	j	8574 <_vsnprintf+0x5c64>
    85cc:	02000c13          	li	s8,32
    85d0:	8f870f63          	beq	a4,s8,76ce <_vsnprintf+0x4dbe>
    85d4:	018707b3          	add	a5,a4,s8
    85d8:	03010f93          	addi	t6,sp,48
    85dc:	01f785b3          	add	a1,a5,t6
    85e0:	07800513          	li	a0,120
    85e4:	fea58023          	sb	a0,-32(a1)
    85e8:	0705                	addi	a4,a4,1
    85ea:	8dcff06f          	j	76c6 <_vsnprintf+0x4db6>
    85ee:	86be                	mv	a3,a5
    85f0:	ddbfe06f          	j	73ca <_vsnprintf+0x4aba>
    85f4:	6382                	ld	t2,0(sp)
    85f6:	4b89                	li	s7,2
    85f8:	8b4fe06f          	j	66ac <_vsnprintf+0x3d9c>
    85fc:	7c0c370b          	th.extu	a4,s8,31,0
    8600:	03010b13          	addi	s6,sp,48
    8604:	e60710e3          	bnez	a4,8464 <_vsnprintf+0x5b54>
    8608:	003ffb13          	andi	s6,t6,3
    860c:	6382                	ld	t2,0(sp)
    860e:	000b1463          	bnez	s6,8616 <_vsnprintf+0x5d06>
    8612:	9ecfe06f          	j	67fe <_vsnprintf+0x3eee>
    8616:	6382                	ld	t2,0(sp)
    8618:	e01e                	sd	t2,0(sp)
    861a:	9e6fe06f          	j	6800 <_vsnprintf+0x3ef0>
    861e:	0001                	nop
    8620:	87de                	mv	a5,s7
    8622:	4ac1                	li	s5,16
    8624:	bbbfc06f          	j	51de <_vsnprintf+0x28ce>
    8628:	dc0b8fe3          	beqz	s7,8406 <_vsnprintf+0x5af6>
    862c:	4c41                	li	s8,16
    862e:	d3868ae3          	beq	a3,s8,8362 <_vsnprintf+0x5a52>
    8632:	4b89                	li	s7,2
    8634:	d37693e3          	bne	a3,s7,835a <_vsnprintf+0x5a4a>
    8638:	b32d                	j	8362 <_vsnprintf+0x5a52>
    863a:	6e02                	ld	t3,0(sp)
    863c:	8dc2                	mv	s11,a6
    863e:	ad7fd06f          	j	6114 <_vsnprintf+0x3804>
    8642:	6a82                	ld	s5,0(sp)
    8644:	cb8fc06f          	j	4afc <_vsnprintf+0x21ec>
    8648:	47fd                	li	a5,31
    864a:	42c1                	li	t0,16
    864c:	1e568063          	beq	a3,t0,882c <_vsnprintf+0x5f1c>
    8650:	4389                	li	t2,2
    8652:	1c768a63          	beq	a3,t2,8826 <_vsnprintf+0x5f16>
    8656:	00278c33          	add	s8,a5,sp
    865a:	03000793          	li	a5,48
    865e:	02fc0823          	sb	a5,48(s8)
    8662:	8d5e                	mv	s10,s7
    8664:	bee5                	j	825c <_vsnprintf+0x594c>
    8666:	4b01                	li	s6,0
    8668:	937fd06f          	j	5f9e <_vsnprintf+0x368e>
    866c:	05800c13          	li	s8,88
    8670:	002d06b3          	add	a3,s10,sp
    8674:	03868723          	sb	s8,46(a3)
    8678:	00288633          	add	a2,a7,sp
    867c:	03000393          	li	t2,48
    8680:	02760823          	sb	t2,48(a2)
    8684:	4b81                	li	s7,0
    8686:	b2bfc06f          	j	51b0 <_vsnprintf+0x28a0>
    868a:	87b6                	mv	a5,a3
    868c:	b6b1                	j	81d8 <_vsnprintf+0x58c8>
    868e:	82e2                	mv	t0,s8
    8690:	fadfa06f          	j	363c <_vsnprintf+0xd2c>
    8694:	02000393          	li	t2,32
    8698:	be7d8d63          	beq	s11,t2,7a92 <_vsnprintf+0x5182>
    869c:	01b80333          	add	t1,a6,s11
    86a0:	8bea                	mv	s7,s10
    86a2:	0d85                	addi	s11,s11,1
    86a4:	06200e93          	li	t4,98
    86a8:	01d30023          	sb	t4,0(t1)
    86ac:	8d5e                	mv	s10,s7
    86ae:	bdcff06f          	j	7a8a <_vsnprintf+0x517a>
    86b2:	00c2f293          	andi	t0,t0,12
    86b6:	fff88c9b          	addiw	s9,a7,-1
    86ba:	7c0c3d0b          	th.extu	s10,s8,31,0
    86be:	425c988b          	th.mvnez	a7,s9,t0
    86c2:	01a7f463          	bgeu	a5,s10,86ca <_vsnprintf+0x5dba>
    86c6:	f74fc06f          	j	4e3a <_vsnprintf+0x252a>
    86ca:	7c08b68b          	th.extu	a3,a7,31,0
    86ce:	00d7f463          	bgeu	a5,a3,86d6 <_vsnprintf+0x5dc6>
    86d2:	c13fe06f          	j	72e4 <_vsnprintf+0x49d4>
    86d6:	02000c13          	li	s8,32
    86da:	b1878263          	beq	a5,s8,79de <_vsnprintf+0x50ce>
    86de:	bb55                	j	8492 <_vsnprintf+0x5b82>
    86e0:	02000c13          	li	s8,32
    86e4:	bb8d8763          	beq	s11,s8,7a92 <_vsnprintf+0x5182>
    86e8:	018d8b33          	add	s6,s11,s8
    86ec:	1818                	addi	a4,sp,48
    86ee:	00eb0fb3          	add	t6,s6,a4
    86f2:	07800693          	li	a3,120
    86f6:	fedf8023          	sb	a3,-32(t6)
    86fa:	0d85                	addi	s11,s11,1
    86fc:	b8eff06f          	j	7a8a <_vsnprintf+0x517a>
    8700:	008afb93          	andi	s7,s5,8
    8704:	060b9d63          	bnez	s7,877e <_vsnprintf+0x5e6e>
    8708:	8c3e                	mv	s8,a5
    870a:	4689                	li	a3,2
    870c:	6302                	ld	t1,0(sp)
    870e:	8b36                	mv	s6,a3
    8710:	8e9fe06f          	j	6ff8 <_vsnprintf+0x46e8>
    8714:	4801                	li	a6,0
    8716:	02067e13          	andi	t3,a2,32
    871a:	040e0363          	beqz	t3,8760 <_vsnprintf+0x5e50>
    871e:	02000d93          	li	s11,32
    8722:	c5bd00e3          	beq	s10,s11,8362 <_vsnprintf+0x5a52>
    8726:	020d0293          	addi	t0,s10,32
    872a:	03010f93          	addi	t6,sp,48
    872e:	01f28f33          	add	t5,t0,t6
    8732:	05800513          	li	a0,88
    8736:	feaf0023          	sb	a0,-32(t5)
    873a:	0d05                	addi	s10,s10,1
    873c:	b939                	j	835a <_vsnprintf+0x5a4a>
    873e:	0001                	nop
    8740:	02000693          	li	a3,32
    8744:	c0dd0fe3          	beq	s10,a3,8362 <_vsnprintf+0x5a52>
    8748:	002d05b3          	add	a1,s10,sp
    874c:	06200713          	li	a4,98
    8750:	02e58823          	sb	a4,48(a1)
    8754:	0d05                	addi	s10,s10,1
    8756:	b111                	j	835a <_vsnprintf+0x5a4a>
    8758:	8bc2                	mv	s7,a6
    875a:	7c0c370b          	th.extu	a4,s8,31,0
    875e:	b985                	j	83ce <_vsnprintf+0x5abe>
    8760:	02000c13          	li	s8,32
    8764:	bf8d0fe3          	beq	s10,s8,8362 <_vsnprintf+0x5a52>
    8768:	018d0bb3          	add	s7,s10,s8
    876c:	181c                	addi	a5,sp,48
    876e:	00fb83b3          	add	t2,s7,a5
    8772:	07800593          	li	a1,120
    8776:	feb38023          	sb	a1,-32(t2)
    877a:	0d05                	addi	s10,s10,1
    877c:	bef9                	j	835a <_vsnprintf+0x5a4a>
    877e:	4b09                	li	s6,2
    8780:	03010293          	addi	t0,sp,48
    8784:	00578d33          	add	s10,a5,t0
    8788:	02000513          	li	a0,32
    878c:	00ad0023          	sb	a0,0(s10)
    8790:	898d                	andi	a1,a1,3
    8792:	00178c13          	addi	s8,a5,1
    8796:	e999                	bnez	a1,87ac <_vsnprintf+0x5e9c>
    8798:	7c08bd0b          	th.extu	s10,a7,31,0
    879c:	01ac7463          	bgeu	s8,s10,87a4 <_vsnprintf+0x5e94>
    87a0:	ec0fe06f          	j	6e60 <_vsnprintf+0x4550>
    87a4:	6302                	ld	t1,0(sp)
    87a6:	8b96                	mv	s7,t0
    87a8:	9eefc06f          	j	4996 <_vsnprintf+0x2086>
    87ac:	6302                	ld	t1,0(sp)
    87ae:	03010b93          	addi	s7,sp,48
    87b2:	9e4fc06f          	j	4996 <_vsnprintf+0x2086>
    87b6:	02000e13          	li	t3,32
    87ba:	01c79463          	bne	a5,t3,87c2 <_vsnprintf+0x5eb2>
    87be:	eeafb06f          	j	3ea8 <_vsnprintf+0x1598>
    87c2:	86be                	mv	a3,a5
    87c4:	f86fc06f          	j	4f4a <_vsnprintf+0x263a>
    87c8:	86be                	mv	a3,a5
    87ca:	01578463          	beq	a5,s5,87d2 <_vsnprintf+0x5ec2>
    87ce:	e3efd06f          	j	5e0c <_vsnprintf+0x34fc>
    87d2:	c5dfe06f          	j	742e <_vsnprintf+0x4b1e>
    87d6:	020e7a93          	andi	s5,t3,32
    87da:	020a9e63          	bnez	s5,8816 <_vsnprintf+0x5f06>
    87de:	07800613          	li	a2,120
    87e2:	02c10823          	sb	a2,48(sp)
    87e6:	03000c93          	li	s9,48
    87ea:	039108a3          	sb	s9,49(sp)
    87ee:	8d5e                	mv	s10,s7
    87f0:	4709                	li	a4,2
    87f2:	bc8d                	j	8264 <_vsnprintf+0x5954>
    87f4:	0085f693          	andi	a3,a1,8
    87f8:	f6c1                	bnez	a3,8780 <_vsnprintf+0x5e70>
    87fa:	003bfa93          	andi	s5,s7,3
    87fe:	8c3e                	mv	s8,a5
    8800:	f00a96e3          	bnez	s5,870c <_vsnprintf+0x5dfc>
    8804:	7c08bd0b          	th.extu	s10,a7,31,0
    8808:	4b01                	li	s6,0
    880a:	4681                	li	a3,0
    880c:	01ac7463          	bgeu	s8,s10,8814 <_vsnprintf+0x5f04>
    8810:	e50fe06f          	j	6e60 <_vsnprintf+0x4550>
    8814:	bde5                	j	870c <_vsnprintf+0x5dfc>
    8816:	05800313          	li	t1,88
    881a:	02610823          	sb	t1,48(sp)
    881e:	8d5e                	mv	s10,s7
    8820:	4705                	li	a4,1
    8822:	c74ff06f          	j	7c96 <_vsnprintf+0x5386>
    8826:	00f80633          	add	a2,a6,a5
    882a:	bee5                	j	8422 <_vsnprintf+0x5b12>
    882c:	020e7e93          	andi	t4,t3,32
    8830:	ffe70d13          	addi	s10,a4,-2
    8834:	040e9463          	bnez	t4,887c <_vsnprintf+0x5f6c>
    8838:	020d0713          	addi	a4,s10,32
    883c:	03010c93          	addi	s9,sp,48
    8840:	019702b3          	add	t0,a4,s9
    8844:	07800393          	li	t2,120
    8848:	fe728023          	sb	t2,-32(t0)
    884c:	8d5e                	mv	s10,s7
    884e:	873e                	mv	a4,a5
    8850:	c46ff06f          	j	7c96 <_vsnprintf+0x5386>
    8854:	c319                	beqz	a4,885a <_vsnprintf+0x5f4a>
    8856:	c63fe06f          	j	74b8 <_vsnprintf+0x4ba8>
    885a:	7c08bc0b          	th.extu	s8,a7,31,0
    885e:	4b81                	li	s7,0
    8860:	f58d6c63          	bltu	s10,s8,7fb8 <_vsnprintf+0x56a8>
    8864:	da0d09e3          	beqz	s10,8616 <_vsnprintf+0x5d06>
    8868:	6382                	ld	t2,0(sp)
    886a:	03010b13          	addi	s6,sp,48
    886e:	e3ffd06f          	j	66ac <_vsnprintf+0x3d9c>
    8872:	6802                	ld	a6,0(sp)
    8874:	02d00513          	li	a0,45
    8878:	f32fd06f          	j	5faa <_vsnprintf+0x369a>
    887c:	020d0b13          	addi	s6,s10,32
    8880:	03010a93          	addi	s5,sp,48
    8884:	015b0333          	add	t1,s6,s5
    8888:	05800613          	li	a2,88
    888c:	177d                	addi	a4,a4,-1
    888e:	fec30023          	sb	a2,-32(t1)
    8892:	8d5e                	mv	s10,s7
    8894:	c02ff06f          	j	7c96 <_vsnprintf+0x5386>
    8898:	45fd                	li	a1,31
    889a:	4dc1                	li	s11,16
    889c:	0bb68363          	beq	a3,s11,8942 <_vsnprintf+0x6032>
    88a0:	4289                	li	t0,2
    88a2:	08568d63          	beq	a3,t0,893c <_vsnprintf+0x602c>
    88a6:	00258533          	add	a0,a1,sp
    88aa:	03000c13          	li	s8,48
    88ae:	03850823          	sb	s8,48(a0)
    88b2:	b96d                	j	856c <_vsnprintf+0x5c5c>
    88b4:	4d01                	li	s10,0
    88b6:	9dcff06f          	j	7a92 <_vsnprintf+0x5182>
    88ba:	cfbc0263          	beq	s8,s11,7d9e <_vsnprintf+0x548e>
    88be:	cfb88063          	beq	a7,s11,7d9e <_vsnprintf+0x548e>
    88c2:	4d01                	li	s10,0
    88c4:	9baff06f          	j	7a7e <_vsnprintf+0x516e>
    88c8:	7c08bc0b          	th.extu	s8,a7,31,0
    88cc:	4d05                	li	s10,1
    88ce:	ef8d6563          	bltu	s10,s8,7fb8 <_vsnprintf+0x56a8>
    88d2:	6382                	ld	t2,0(sp)
    88d4:	dd9fd06f          	j	66ac <_vsnprintf+0x3d9c>
    88d8:	02067c93          	andi	s9,a2,32
    88dc:	020c9163          	bnez	s9,88fe <_vsnprintf+0x5fee>
    88e0:	07800693          	li	a3,120
    88e4:	02d10823          	sb	a3,48(sp)
    88e8:	03000e13          	li	t3,48
    88ec:	03c108a3          	sb	t3,49(sp)
    88f0:	4d09                	li	s10,2
    88f2:	b149                	j	8574 <_vsnprintf+0x5c64>
    88f4:	06200e93          	li	t4,98
    88f8:	03d10823          	sb	t4,48(sp)
    88fc:	b7f5                	j	88e8 <_vsnprintf+0x5fd8>
    88fe:	05800313          	li	t1,88
    8902:	02610823          	sb	t1,48(sp)
    8906:	885e                	mv	a6,s7
    8908:	4d05                	li	s10,1
    890a:	b155                	j	85ae <_vsnprintf+0x5c9e>
    890c:	4d41                	li	s10,16
    890e:	e1a68563          	beq	a3,s10,7f18 <_vsnprintf+0x5608>
    8912:	4509                	li	a0,2
    8914:	00a68e63          	beq	a3,a0,8930 <_vsnprintf+0x6020>
    8918:	02000313          	li	t1,32
    891c:	4d01                	li	s10,0
    891e:	986d8063          	beq	s11,t1,7a9e <_vsnprintf+0x518e>
    8922:	c06ff06f          	j	7d28 <_vsnprintf+0x5418>
    8926:	02000613          	li	a2,32
    892a:	c2cd8163          	beq	s11,a2,7d4c <_vsnprintf+0x543c>
    892e:	bef1                	j	850a <_vsnprintf+0x5bfa>
    8930:	02000e93          	li	t4,32
    8934:	4d01                	li	s10,0
    8936:	97dd8463          	beq	s11,t4,7a9e <_vsnprintf+0x518e>
    893a:	b38d                	j	869c <_vsnprintf+0x5d8c>
    893c:	885e                	mv	a6,s7
    893e:	8d2e                	mv	s10,a1
    8940:	b521                	j	8748 <_vsnprintf+0x5e38>
    8942:	ffed0813          	addi	a6,s10,-2
    8946:	02067c93          	andi	s9,a2,32
    894a:	1d7d                	addi	s10,s10,-1
    894c:	02080313          	addi	t1,a6,32
    8950:	080c9263          	bnez	s9,89d4 <_vsnprintf+0x60c4>
    8954:	03010293          	addi	t0,sp,48
    8958:	00530fb3          	add	t6,t1,t0
    895c:	07800f13          	li	t5,120
    8960:	ffef8023          	sb	t5,-32(t6)
    8964:	885e                	mv	a6,s7
    8966:	b1a1                	j	85ae <_vsnprintf+0x5c9e>
    8968:	02067b13          	andi	s6,a2,32
    896c:	020b1563          	bnez	s6,8996 <_vsnprintf+0x6086>
    8970:	07800693          	li	a3,120
    8974:	02d10823          	sb	a3,48(sp)
    8978:	03000f93          	li	t6,48
    897c:	03f108a3          	sb	t6,49(sp)
    8980:	4d89                	li	s11,2
    8982:	c40ff06f          	j	7dc2 <_vsnprintf+0x54b2>
    8986:	000e8f63          	beqz	t4,89a4 <_vsnprintf+0x6094>
    898a:	4801                	li	a6,0
    898c:	9c0b91e3          	bnez	s7,834e <_vsnprintf+0x5a3e>
    8990:	9aed1fe3          	bne	s10,a4,834e <_vsnprintf+0x5a3e>
    8994:	b4a1                	j	83dc <_vsnprintf+0x5acc>
    8996:	05800713          	li	a4,88
    899a:	02e10823          	sb	a4,48(sp)
    899e:	4d85                	li	s11,1
    89a0:	b88ff06f          	j	7d28 <_vsnprintf+0x5418>
    89a4:	02000c13          	li	s8,32
    89a8:	4b81                	li	s7,0
    89aa:	bd8d15e3          	bne	s10,s8,8574 <_vsnprintf+0x5c64>
    89ae:	cf7fd06f          	j	66a4 <_vsnprintf+0x3d94>
    89b2:	4ac1                	li	s5,16
    89b4:	4b89                	li	s7,2
    89b6:	fe2ff06f          	j	8198 <_vsnprintf+0x5888>
    89ba:	6382                	ld	t2,0(sp)
    89bc:	4b81                	li	s7,0
    89be:	ceffd06f          	j	66ac <_vsnprintf+0x3d9c>
    89c2:	01c80333          	add	t1,a6,t3
    89c6:	b9f9                	j	86a4 <_vsnprintf+0x5d94>
    89c8:	02000e93          	li	t4,32
    89cc:	4b81                	li	s7,0
    89ce:	dddd0f63          	beq	s10,t4,7fac <_vsnprintf+0x569c>
    89d2:	b561                	j	885a <_vsnprintf+0x5f4a>
    89d4:	1814                	addi	a3,sp,48
    89d6:	00d30e33          	add	t3,t1,a3
    89da:	05800d93          	li	s11,88
    89de:	ffbe0023          	sb	s11,-32(t3)
    89e2:	885e                	mv	a6,s7
    89e4:	b6e9                	j	85ae <_vsnprintf+0x5c9e>
    89e6:	05800593          	li	a1,88
    89ea:	feb28023          	sb	a1,-32(t0)
    89ee:	8d5e                	mv	s10,s7
    89f0:	b38ff06f          	j	7d28 <_vsnprintf+0x5418>
    89f4:	8dc2                	mv	s11,a6
    89f6:	4b01                	li	s6,0
    89f8:	6802                	ld	a6,0(sp)
    89fa:	8c96                	mv	s9,t0
    89fc:	daefd06f          	j	5faa <_vsnprintf+0x369a>
    8a00:	0085ff93          	andi	t6,a1,8
    8a04:	060f9263          	bnez	t6,8a68 <_vsnprintf+0x6158>
    8a08:	003cfe93          	andi	t4,s9,3
    8a0c:	8c3e                	mv	s8,a5
    8a0e:	b40e91e3          	bnez	t4,8550 <_vsnprintf+0x5c40>
    8a12:	7c08bb8b          	th.extu	s7,a7,31,0
    8a16:	8dc2                	mv	s11,a6
    8a18:	4b01                	li	s6,0
    8a1a:	4f81                	li	t6,0
    8a1c:	017c7463          	bgeu	s8,s7,8a24 <_vsnprintf+0x6114>
    8a20:	fa5fd06f          	j	69c4 <_vsnprintf+0x40b4>
    8a24:	b635                	j	8550 <_vsnprintf+0x5c40>
    8a26:	6302                	ld	t1,0(sp)
    8a28:	4b01                	li	s6,0
    8a2a:	f6dfb06f          	j	4996 <_vsnprintf+0x2086>
    8a2e:	8dc2                	mv	s11,a6
    8a30:	4b09                	li	s6,2
    8a32:	1818                	addi	a4,sp,48
    8a34:	00e78f33          	add	t5,a5,a4
    8a38:	02000513          	li	a0,32
    8a3c:	00af0023          	sb	a0,0(t5)
    8a40:	0035fd13          	andi	s10,a1,3
    8a44:	00178c13          	addi	s8,a5,1
    8a48:	020d1263          	bnez	s10,8a6c <_vsnprintf+0x615c>
    8a4c:	7c08bb8b          	th.extu	s7,a7,31,0
    8a50:	017c7463          	bgeu	s8,s7,8a58 <_vsnprintf+0x6148>
    8a54:	f71fd06f          	j	69c4 <_vsnprintf+0x40b4>
    8a58:	6802                	ld	a6,0(sp)
    8a5a:	8cba                	mv	s9,a4
    8a5c:	d4efd06f          	j	5faa <_vsnprintf+0x369a>
    8a60:	008afb93          	andi	s7,s5,8
    8a64:	fa0b87e3          	beqz	s7,8a12 <_vsnprintf+0x6102>
    8a68:	8dc2                	mv	s11,a6
    8a6a:	b7e1                	j	8a32 <_vsnprintf+0x6122>
    8a6c:	6802                	ld	a6,0(sp)
    8a6e:	03010c93          	addi	s9,sp,48
    8a72:	d38fd06f          	j	5faa <_vsnprintf+0x369a>
    8a76:	851e                	mv	a0,t2
    8a78:	8dc2                	mv	s11,a6
    8a7a:	6382                	ld	t2,0(sp)
    8a7c:	4b01                	li	s6,0
    8a7e:	03010313          	addi	t1,sp,48
    8a82:	c32fb06f          	j	3eb4 <_vsnprintf+0x15a4>
    8a86:	0085fa93          	andi	s5,a1,8
    8a8a:	040a8563          	beqz	s5,8ad4 <_vsnprintf+0x61c4>
    8a8e:	8dc2                	mv	s11,a6
    8a90:	02078813          	addi	a6,a5,32
    8a94:	03010293          	addi	t0,sp,48
    8a98:	00580cb3          	add	s9,a6,t0
    8a9c:	02000c13          	li	s8,32
    8aa0:	ff8c8023          	sb	s8,-32(s9)
    8aa4:	0035fb93          	andi	s7,a1,3
    8aa8:	00178d13          	addi	s10,a5,1
    8aac:	000b9863          	bnez	s7,8abc <_vsnprintf+0x61ac>
    8ab0:	7c08bb8b          	th.extu	s7,a7,31,0
    8ab4:	017d7463          	bgeu	s10,s7,8abc <_vsnprintf+0x61ac>
    8ab8:	cbcfc06f          	j	4f74 <_vsnprintf+0x2664>
    8abc:	6382                	ld	t2,0(sp)
    8abe:	8562                	mv	a0,s8
    8ac0:	03010313          	addi	t1,sp,48
    8ac4:	bf0fb06f          	j	3eb4 <_vsnprintf+0x15a4>
    8ac8:	02000293          	li	t0,32
    8acc:	4801                	li	a6,0
    8ace:	8a5d00e3          	beq	s10,t0,836e <_vsnprintf+0x5a5e>
    8ad2:	b99d                	j	8748 <_vsnprintf+0x5e38>
    8ad4:	00337e13          	andi	t3,t1,3
    8ad8:	8d3e                	mv	s10,a5
    8ada:	000e1b63          	bnez	t3,8af0 <_vsnprintf+0x61e0>
    8ade:	7c08bb8b          	th.extu	s7,a7,31,0
    8ae2:	8dc2                	mv	s11,a6
    8ae4:	4b01                	li	s6,0
    8ae6:	4a81                	li	s5,0
    8ae8:	017d7463          	bgeu	s10,s7,8af0 <_vsnprintf+0x61e0>
    8aec:	c88fc06f          	j	4f74 <_vsnprintf+0x2664>
    8af0:	6382                	ld	t2,0(sp)
    8af2:	8dc2                	mv	s11,a6
    8af4:	8b56                	mv	s6,s5
    8af6:	e12fc06f          	j	5108 <_vsnprintf+0x27f8>
    8afa:	7c08bc0b          	th.extu	s8,a7,31,0
    8afe:	4d85                	li	s11,1
    8b00:	018df463          	bgeu	s11,s8,8b08 <_vsnprintf+0x61f8>
    8b04:	fadfe06f          	j	7ab0 <_vsnprintf+0x51a0>
    8b08:	6682                	ld	a3,0(sp)
    8b0a:	dfffc06f          	j	5908 <_vsnprintf+0x2ff8>
    8b0e:	06200c13          	li	s8,98
    8b12:	03810823          	sb	s8,48(sp)
    8b16:	b58d                	j	8978 <_vsnprintf+0x6068>
    8b18:	004afb13          	andi	s6,s5,4
    8b1c:	f40b02e3          	beqz	s6,8a60 <_vsnprintf+0x6150>
    8b20:	02b00b13          	li	s6,43
    8b24:	03610823          	sb	s6,48(sp)
    8b28:	4c05                	li	s8,1
    8b2a:	ed8ff06f          	j	8202 <_vsnprintf+0x58f2>
    8b2e:	0082f313          	andi	t1,t0,8
    8b32:	02031463          	bnez	t1,8b5a <_vsnprintf+0x624a>
    8b36:	8d3e                	mv	s10,a5
    8b38:	4a89                	li	s5,2
    8b3a:	bf5d                	j	8af0 <_vsnprintf+0x61e0>
    8b3c:	03000e93          	li	t4,48
    8b40:	47bd                	li	a5,15
    8b42:	03d10823          	sb	t4,48(sp)
    8b46:	4b81                	li	s7,0
    8b48:	4d01                	li	s10,0
    8b4a:	40000c93          	li	s9,1024
    8b4e:	4e05                	li	t3,1
    8b50:	8abe                	mv	s5,a5
    8b52:	03010b13          	addi	s6,sp,48
    8b56:	eecfb06f          	j	4242 <_vsnprintf+0x1932>
    8b5a:	8dc2                	mv	s11,a6
    8b5c:	4b09                	li	s6,2
    8b5e:	bf0d                	j	8a90 <_vsnprintf+0x6180>
    8b60:	000e8463          	beqz	t4,8b68 <_vsnprintf+0x6258>
    8b64:	b53fe06f          	j	76b6 <_vsnprintf+0x4da6>
    8b68:	02000b93          	li	s7,32
    8b6c:	01771463          	bne	a4,s7,8b74 <_vsnprintf+0x6264>
    8b70:	849fc06f          	j	53b8 <_vsnprintf+0x2aa8>
    8b74:	9fcfe06f          	j	6d70 <_vsnprintf+0x4460>
    8b78:	7c08bf8b          	th.extu	t6,a7,31,0
    8b7c:	01f7f463          	bgeu	a5,t6,8b84 <_vsnprintf+0x6274>
    8b80:	81dfd06f          	j	639c <_vsnprintf+0x3a8c>
    8b84:	02000e13          	li	t3,32
    8b88:	01c79463          	bne	a5,t3,8b90 <_vsnprintf+0x6280>
    8b8c:	e01fb06f          	j	498c <_vsnprintf+0x207c>
    8b90:	903fd06f          	j	6492 <_vsnprintf+0x3b82>
    8b94:	02000513          	li	a0,32
    8b98:	02a79463          	bne	a5,a0,8bc0 <_vsnprintf+0x62b0>
    8b9c:	0036fa93          	andi	s5,a3,3
    8ba0:	000a9463          	bnez	s5,8ba8 <_vsnprintf+0x6298>
    8ba4:	897fe06f          	j	743a <_vsnprintf+0x4b2a>
    8ba8:	bf6fd06f          	j	5f9e <_vsnprintf+0x368e>
    8bac:	f80e9f63          	bnez	t4,834a <_vsnprintf+0x5a3a>
    8bb0:	02000713          	li	a4,32
    8bb4:	00ed1463          	bne	s10,a4,8bbc <_vsnprintf+0x62ac>
    8bb8:	aedfd06f          	j	66a4 <_vsnprintf+0x3d94>
    8bbc:	ae1fe06f          	j	769c <_vsnprintf+0x4d8c>
    8bc0:	86be                	mv	a3,a5
    8bc2:	a4afd06f          	j	5e0c <_vsnprintf+0x34fc>
    8bc6:	020e8a63          	beqz	t4,8bfa <_vsnprintf+0x62ea>
    8bca:	4d01                	li	s10,0
    8bcc:	000b8463          	beqz	s7,8bd4 <_vsnprintf+0x62c4>
    8bd0:	aebfe06f          	j	76ba <_vsnprintf+0x4daa>
    8bd4:	00a70463          	beq	a4,a0,8bdc <_vsnprintf+0x62cc>
    8bd8:	ae3fe06f          	j	76ba <_vsnprintf+0x4daa>
    8bdc:	e57fe06f          	j	7a32 <_vsnprintf+0x5122>
    8be0:	020d0663          	beqz	s10,8c0c <_vsnprintf+0x62fc>
    8be4:	4d01                	li	s10,0
    8be6:	000b8463          	beqz	s7,8bee <_vsnprintf+0x62de>
    8bea:	e95fe06f          	j	7a7e <_vsnprintf+0x516e>
    8bee:	00ad8463          	beq	s11,a0,8bf6 <_vsnprintf+0x62e6>
    8bf2:	e8dfe06f          	j	7a7e <_vsnprintf+0x516e>
    8bf6:	97cff06f          	j	7d72 <_vsnprintf+0x5462>
    8bfa:	02000b93          	li	s7,32
    8bfe:	01771463          	bne	a4,s7,8c06 <_vsnprintf+0x62f6>
    8c02:	fb6fc06f          	j	53b8 <_vsnprintf+0x2aa8>
    8c06:	4d01                	li	s10,0
    8c08:	e5cff06f          	j	8264 <_vsnprintf+0x5954>
    8c0c:	02000b93          	li	s7,32
    8c10:	9b7d9963          	bne	s11,s7,7dc2 <_vsnprintf+0x54b2>
    8c14:	4d01                	li	s10,0
    8c16:	cedfc06f          	j	5902 <_vsnprintf+0x2ff2>
    8c1a:	00457b93          	andi	s7,a0,4
    8c1e:	020b9a63          	bnez	s7,8c52 <_vsnprintf+0x6342>
    8c22:	00857593          	andi	a1,a0,8
    8c26:	e18d                	bnez	a1,8c48 <_vsnprintf+0x6338>
    8c28:	020d0c93          	addi	s9,s10,32
    8c2c:	1810                	addi	a2,sp,48
    8c2e:	00cc8fb3          	add	t6,s9,a2
    8c32:	fdffc503          	lbu	a0,-33(t6)
    8c36:	4b89                	li	s7,2
    8c38:	4ac1                	li	s5,16
    8c3a:	9d3fb06f          	j	460c <_vsnprintf+0x1cfc>
    8c3e:	47fd                	li	a5,31
    8c40:	4ac1                	li	s5,16
    8c42:	4b89                	li	s7,2
    8c44:	d54ff06f          	j	8198 <_vsnprintf+0x5888>
    8c48:	87ea                	mv	a5,s10
    8c4a:	4b89                	li	s7,2
    8c4c:	4ac1                	li	s5,16
    8c4e:	d90fc06f          	j	51de <_vsnprintf+0x28ce>
    8c52:	87ea                	mv	a5,s10
    8c54:	4b89                	li	s7,2
    8c56:	4ac1                	li	s5,16
    8c58:	958fc06f          	j	4db0 <_vsnprintf+0x24a0>
    8c5c:	02000513          	li	a0,32
    8c60:	0ea79e63          	bne	a5,a0,8d5c <_vsnprintf+0x644c>
    8c64:	0032fe93          	andi	t4,t0,3
    8c68:	000e9463          	bnez	t4,8c70 <_vsnprintf+0x6360>
    8c6c:	d7ffe06f          	j	79ea <_vsnprintf+0x50da>
    8c70:	a38fb06f          	j	3ea8 <_vsnprintf+0x1598>
    8c74:	02000813          	li	a6,32
    8c78:	01078463          	beq	a5,a6,8c80 <_vsnprintf+0x6370>
    8c7c:	80ffd06f          	j	648a <_vsnprintf+0x3b7a>
    8c80:	003afe93          	andi	t4,s5,3
    8c84:	000e9463          	bnez	t4,8c8c <_vsnprintf+0x637c>
    8c88:	ba0fe06f          	j	7028 <_vsnprintf+0x4718>
    8c8c:	d01fb06f          	j	498c <_vsnprintf+0x207c>
    8c90:	6382                	ld	t2,0(sp)
    8c92:	02d00513          	li	a0,45
    8c96:	a1efb06f          	j	3eb4 <_vsnprintf+0x15a4>
    8c9a:	6382                	ld	t2,0(sp)
    8c9c:	8dc2                	mv	s11,a6
    8c9e:	8532                	mv	a0,a2
    8ca0:	4b01                	li	s6,0
    8ca2:	a12fb06f          	j	3eb4 <_vsnprintf+0x15a4>
    8ca6:	0001                	nop
    8ca8:	87b6                	mv	a5,a3
    8caa:	fe8ff06f          	j	8492 <_vsnprintf+0x5b82>
    8cae:	004afb13          	andi	s6,s5,4
    8cb2:	040b0263          	beqz	s6,8cf6 <_vsnprintf+0x63e6>
    8cb6:	02b00b13          	li	s6,43
    8cba:	03610823          	sb	s6,48(sp)
    8cbe:	4d05                	li	s10,1
    8cc0:	ffcff06f          	j	84bc <_vsnprintf+0x5bac>
    8cc4:	00778463          	beq	a5,t2,8ccc <_vsnprintf+0x63bc>
    8cc8:	fc2fd06f          	j	648a <_vsnprintf+0x3b7a>
    8ccc:	b80fe06f          	j	704c <_vsnprintf+0x473c>
    8cd0:	02000c13          	li	s8,32
    8cd4:	81871de3          	bne	a4,s8,84ee <_vsnprintf+0x5bde>
    8cd8:	4d01                	li	s10,0
    8cda:	cadfe06f          	j	7986 <_vsnprintf+0x5076>
    8cde:	02000513          	li	a0,32
    8ce2:	4d01                	li	s10,0
    8ce4:	00a71463          	bne	a4,a0,8cec <_vsnprintf+0x63dc>
    8ce8:	9f1fe06f          	j	76d8 <_vsnprintf+0x4dc8>
    8cec:	f2eff06f          	j	841a <_vsnprintf+0x5b0a>
    8cf0:	4b01                	li	s6,0
    8cf2:	9b6fb06f          	j	3ea8 <_vsnprintf+0x1598>
    8cf6:	008af393          	andi	t2,s5,8
    8cfa:	d8039ae3          	bnez	t2,8a8e <_vsnprintf+0x617e>
    8cfe:	b3c5                	j	8ade <_vsnprintf+0x61ce>
    8d00:	6302                	ld	t1,0(sp)
    8d02:	02b00513          	li	a0,43
    8d06:	03010b93          	addi	s7,sp,48
    8d0a:	c8dfb06f          	j	4996 <_vsnprintf+0x2086>
    8d0e:	008d7f13          	andi	t5,s10,8
    8d12:	a60f17e3          	bnez	t5,8780 <_vsnprintf+0x5e70>
    8d16:	b4fd                	j	8804 <_vsnprintf+0x5ef4>
    8d18:	6e02                	ld	t3,0(sp)
    8d1a:	4d01                	li	s10,0
    8d1c:	ea2fc06f          	j	53be <_vsnprintf+0x2aae>
    8d20:	7c08bc0b          	th.extu	s8,a7,31,0
    8d24:	4705                	li	a4,1
    8d26:	8d5e                	mv	s10,s7
    8d28:	01877463          	bgeu	a4,s8,8d30 <_vsnprintf+0x6420>
    8d2c:	9bdfe06f          	j	76e8 <_vsnprintf+0x4dd8>
    8d30:	6e02                	ld	t3,0(sp)
    8d32:	e8cfc06f          	j	53be <_vsnprintf+0x2aae>
    8d36:	06200b13          	li	s6,98
    8d3a:	03610823          	sb	s6,48(sp)
    8d3e:	b465                	j	87e6 <_vsnprintf+0x5ed6>
    8d40:	03000793          	li	a5,48
    8d44:	02f10823          	sb	a5,48(sp)
    8d48:	47c1                	li	a5,16
    8d4a:	4d01                	li	s10,0
    8d4c:	40000c93          	li	s9,1024
    8d50:	4e05                	li	t3,1
    8d52:	8abe                	mv	s5,a5
    8d54:	03010b13          	addi	s6,sp,48
    8d58:	ceafb06f          	j	4242 <_vsnprintf+0x1932>
    8d5c:	86be                	mv	a3,a5
    8d5e:	9e4fc06f          	j	4f42 <_vsnprintf+0x2632>
    8d62:	0001                	nop
    8d64:	00000013          	nop
    8d68:	00000013          	nop
    8d6c:	00000013          	nop

0000000000008d70 <puts>:
    8d70:	1141                	addi	sp,sp,-16
    8d72:	f811540b          	th.sdd	s0,ra,(sp),0,4
    8d76:	842a                	mv	s0,a0
    8d78:	00054503          	lbu	a0,0(a0)
    8d7c:	c12d                	beqz	a0,8dde <puts+0x6e>
    8d7e:	55fd                	li	a1,-1
    8d80:	890f80ef          	jal	e10 <fputc>
    8d84:	00144503          	lbu	a0,1(s0)
    8d88:	c939                	beqz	a0,8dde <puts+0x6e>
    8d8a:	55fd                	li	a1,-1
    8d8c:	884f80ef          	jal	e10 <fputc>
    8d90:	00244503          	lbu	a0,2(s0)
    8d94:	c529                	beqz	a0,8dde <puts+0x6e>
    8d96:	55fd                	li	a1,-1
    8d98:	878f80ef          	jal	e10 <fputc>
    8d9c:	00344503          	lbu	a0,3(s0)
    8da0:	cd1d                	beqz	a0,8dde <puts+0x6e>
    8da2:	55fd                	li	a1,-1
    8da4:	86cf80ef          	jal	e10 <fputc>
    8da8:	00444503          	lbu	a0,4(s0)
    8dac:	c90d                	beqz	a0,8dde <puts+0x6e>
    8dae:	55fd                	li	a1,-1
    8db0:	860f80ef          	jal	e10 <fputc>
    8db4:	00544503          	lbu	a0,5(s0)
    8db8:	c11d                	beqz	a0,8dde <puts+0x6e>
    8dba:	55fd                	li	a1,-1
    8dbc:	854f80ef          	jal	e10 <fputc>
    8dc0:	00644503          	lbu	a0,6(s0)
    8dc4:	cd09                	beqz	a0,8dde <puts+0x6e>
    8dc6:	55fd                	li	a1,-1
    8dc8:	848f80ef          	jal	e10 <fputc>
    8dcc:	00744503          	lbu	a0,7(s0)
    8dd0:	c519                	beqz	a0,8dde <puts+0x6e>
    8dd2:	55fd                	li	a1,-1
    8dd4:	83cf80ef          	jal	e10 <fputc>
    8dd8:	8884450b          	th.lbuib	a0,(s0),8,0
    8ddc:	f14d                	bnez	a0,8d7e <puts+0xe>
    8dde:	55fd                	li	a1,-1
    8de0:	4529                	li	a0,10
    8de2:	82ef80ef          	jal	e10 <fputc>
    8de6:	f811440b          	th.ldd	s0,ra,(sp),0,4
    8dea:	4501                	li	a0,0
    8dec:	0141                	addi	sp,sp,16
    8dee:	8082                	ret

0000000000008df0 <_putchar>:
    8df0:	55fd                	li	a1,-1
    8df2:	81ef806f          	j	e10 <fputc>
    8df6:	00000013          	nop
    8dfa:	00000013          	nop
    8dfe:	0001                	nop

0000000000008e00 <putchar>:
    8e00:	1141                	addi	sp,sp,-16
    8e02:	55fd                	li	a1,-1
    8e04:	0ff57513          	zext.b	a0,a0
    8e08:	e406                	sd	ra,8(sp)
    8e0a:	806f80ef          	jal	e10 <fputc>
    8e0e:	60a2                	ld	ra,8(sp)
    8e10:	4501                	li	a0,0
    8e12:	0141                	addi	sp,sp,16
    8e14:	8082                	ret
    8e16:	00000013          	nop
    8e1a:	00000013          	nop
    8e1e:	0001                	nop

0000000000008e20 <printf>:
    8e20:	711d                	addi	sp,sp,-96
    8e22:	fed1560b          	th.sdd	a2,a3,(sp),3,4
    8e26:	86aa                	mv	a3,a0
    8e28:	6505                	lui	a0,0x1
    8e2a:	e0ba                	sd	a4,64(sp)
    8e2c:	e4be                	sd	a5,72(sp)
    8e2e:	f42e                	sd	a1,40(sp)
    8e30:	1038                	addi	a4,sp,40
    8e32:	858a                	mv	a1,sp
    8e34:	567d                	li	a2,-1
    8e36:	e7050513          	addi	a0,a0,-400 # e70 <_out_char>
    8e3a:	ec06                	sd	ra,24(sp)
    8e3c:	e8c2                	sd	a6,80(sp)
    8e3e:	ecc6                	sd	a7,88(sp)
    8e40:	e43a                	sd	a4,8(sp)
    8e42:	acff90ef          	jal	2910 <_vsnprintf>
    8e46:	60e2                	ld	ra,24(sp)
    8e48:	6125                	addi	sp,sp,96
    8e4a:	8082                	ret
    8e4c:	00000013          	nop

0000000000008e50 <sprintf>:
    8e50:	715d                	addi	sp,sp,-80
    8e52:	fcd1560b          	th.sdd	a2,a3,(sp),2,4
    8e56:	86ae                	mv	a3,a1
    8e58:	85aa                	mv	a1,a0
    8e5a:	6505                	lui	a0,0x1
    8e5c:	fef1570b          	th.sdd	a4,a5,(sp),3,4
    8e60:	567d                	li	a2,-1
    8e62:	1018                	addi	a4,sp,32
    8e64:	e4050513          	addi	a0,a0,-448 # e40 <_out_buffer>
    8e68:	ec06                	sd	ra,24(sp)
    8e6a:	e0c2                	sd	a6,64(sp)
    8e6c:	e4c6                	sd	a7,72(sp)
    8e6e:	e43a                	sd	a4,8(sp)
    8e70:	aa1f90ef          	jal	2910 <_vsnprintf>
    8e74:	60e2                	ld	ra,24(sp)
    8e76:	6161                	addi	sp,sp,80
    8e78:	8082                	ret
    8e7a:	00000013          	nop
    8e7e:	0001                	nop

0000000000008e80 <snprintf>:
    8e80:	715d                	addi	sp,sp,-80
    8e82:	f436                	sd	a3,40(sp)
    8e84:	86b2                	mv	a3,a2
    8e86:	862e                	mv	a2,a1
    8e88:	85aa                	mv	a1,a0
    8e8a:	6505                	lui	a0,0x1
    8e8c:	fef1570b          	th.sdd	a4,a5,(sp),3,4
    8e90:	e4050513          	addi	a0,a0,-448 # e40 <_out_buffer>
    8e94:	1038                	addi	a4,sp,40
    8e96:	ec06                	sd	ra,24(sp)
    8e98:	e0c2                	sd	a6,64(sp)
    8e9a:	e4c6                	sd	a7,72(sp)
    8e9c:	e43a                	sd	a4,8(sp)
    8e9e:	a73f90ef          	jal	2910 <_vsnprintf>
    8ea2:	60e2                	ld	ra,24(sp)
    8ea4:	6161                	addi	sp,sp,80
    8ea6:	8082                	ret
    8ea8:	00000013          	nop
    8eac:	00000013          	nop

0000000000008eb0 <vprintf>:
    8eb0:	1101                	addi	sp,sp,-32
    8eb2:	86aa                	mv	a3,a0
    8eb4:	6505                	lui	a0,0x1
    8eb6:	872e                	mv	a4,a1
    8eb8:	567d                	li	a2,-1
    8eba:	002c                	addi	a1,sp,8
    8ebc:	e7050513          	addi	a0,a0,-400 # e70 <_out_char>
    8ec0:	ec06                	sd	ra,24(sp)
    8ec2:	a4ff90ef          	jal	2910 <_vsnprintf>
    8ec6:	60e2                	ld	ra,24(sp)
    8ec8:	6105                	addi	sp,sp,32
    8eca:	8082                	ret
    8ecc:	00000013          	nop

0000000000008ed0 <vsnprintf>:
    8ed0:	8736                	mv	a4,a3
    8ed2:	86b2                	mv	a3,a2
    8ed4:	862e                	mv	a2,a1
    8ed6:	85aa                	mv	a1,a0
    8ed8:	6505                	lui	a0,0x1
    8eda:	e4050513          	addi	a0,a0,-448 # e40 <_out_buffer>
    8ede:	a33f906f          	j	2910 <_vsnprintf>
    8ee2:	0001                	nop
    8ee4:	00000013          	nop
    8ee8:	00000013          	nop
    8eec:	00000013          	nop

0000000000008ef0 <fctprintf>:
    8ef0:	711d                	addi	sp,sp,-96
    8ef2:	fc36                	sd	a3,56(sp)
    8ef4:	e0ba                	sd	a4,64(sp)
    8ef6:	1838                	addi	a4,sp,56
    8ef8:	e43a                	sd	a4,8(sp)
    8efa:	e82a                	sd	a0,16(sp)
    8efc:	6505                	lui	a0,0x1
    8efe:	ec2e                	sd	a1,24(sp)
    8f00:	86b2                	mv	a3,a2
    8f02:	080c                	addi	a1,sp,16
    8f04:	567d                	li	a2,-1
    8f06:	e6050513          	addi	a0,a0,-416 # e60 <_out_fct>
    8f0a:	f406                	sd	ra,40(sp)
    8f0c:	e4be                	sd	a5,72(sp)
    8f0e:	e8c2                	sd	a6,80(sp)
    8f10:	ecc6                	sd	a7,88(sp)
    8f12:	9fff90ef          	jal	2910 <_vsnprintf>
    8f16:	70a2                	ld	ra,40(sp)
    8f18:	6125                	addi	sp,sp,96
    8f1a:	8082                	ret
    8f1c:	0000                	unimp
	...

0000000000008f20 <ck_uart_set_baudrate>:
    8f20:	05f5e737          	lui	a4,0x5f5e
    8f24:	1007029b          	addiw	t0,a4,256 # 5f5e100 <__kernel_stack+0x5e70100>
    8f28:	02b2d33b          	divuw	t1,t0,a1
    8f2c:	651c                	ld	a5,8(a0)
    8f2e:	c90c                	sw	a1,16(a0)
    8f30:	00c7c683          	lbu	a3,12(a5)
    8f34:	0806e393          	ori	t2,a3,128
    8f38:	00778623          	sb	t2,12(a5)
    8f3c:	2c43350b          	th.extu	a0,t1,11,4
    8f40:	00a78023          	sb	a0,0(a5)
    8f44:	4cc3358b          	th.extu	a1,t1,19,12
    8f48:	00b78223          	sb	a1,4(a5)
    8f4c:	00c7c603          	lbu	a2,12(a5)
    8f50:	07f67813          	andi	a6,a2,127
    8f54:	01078623          	sb	a6,12(a5)
    8f58:	8082                	ret
    8f5a:	00000013          	nop
    8f5e:	0001                	nop

0000000000008f60 <ck_uart_set_parity>:
    8f60:	4785                	li	a5,1
    8f62:	c94c                	sw	a1,20(a0)
    8f64:	04f58063          	beq	a1,a5,8fa4 <ck_uart_set_parity+0x44>
    8f68:	4609                	li	a2,2
    8f6a:	00c58d63          	beq	a1,a2,8f84 <ck_uart_set_parity+0x24>
    8f6e:	e995                	bnez	a1,8fa2 <ck_uart_set_parity+0x42>
    8f70:	00853f83          	ld	t6,8(a0)
    8f74:	00cfc783          	lbu	a5,12(t6)
    8f78:	0f77f713          	andi	a4,a5,247
    8f7c:	00ef8623          	sb	a4,12(t6)
    8f80:	8082                	ret
    8f82:	0001                	nop
    8f84:	6514                	ld	a3,8(a0)
    8f86:	00c6c803          	lbu	a6,12(a3)
    8f8a:	00886893          	ori	a7,a6,8
    8f8e:	01168623          	sb	a7,12(a3)
    8f92:	00853e03          	ld	t3,8(a0)
    8f96:	00ce4e83          	lbu	t4,12(t3)
    8f9a:	010eef13          	ori	t5,t4,16
    8f9e:	01ee0623          	sb	t5,12(t3)
    8fa2:	8082                	ret
    8fa4:	6518                	ld	a4,8(a0)
    8fa6:	00c74283          	lbu	t0,12(a4)
    8faa:	0082e313          	ori	t1,t0,8
    8fae:	00670623          	sb	t1,12(a4)
    8fb2:	00853383          	ld	t2,8(a0)
    8fb6:	00c3c503          	lbu	a0,12(t2)
    8fba:	0ef57593          	andi	a1,a0,239
    8fbe:	00b38623          	sb	a1,12(t2)
    8fc2:	8082                	ret
    8fc4:	00000013          	nop
    8fc8:	00000013          	nop
    8fcc:	00000013          	nop

0000000000008fd0 <ck_uart_set_wordsize>:
    8fd0:	4789                	li	a5,2
    8fd2:	cd4c                	sw	a1,28(a0)
    8fd4:	04f58263          	beq	a1,a5,9018 <ck_uart_set_wordsize+0x48>
    8fd8:	02b7e463          	bltu	a5,a1,9000 <ck_uart_set_wordsize+0x30>
    8fdc:	cdb1                	beqz	a1,9038 <ck_uart_set_wordsize+0x68>
    8fde:	00853f83          	ld	t6,8(a0)
    8fe2:	00cfc783          	lbu	a5,12(t6)
    8fe6:	0fd7f713          	andi	a4,a5,253
    8fea:	00ef8623          	sb	a4,12(t6)
    8fee:	00853283          	ld	t0,8(a0)
    8ff2:	00c2c303          	lbu	t1,12(t0)
    8ff6:	00136393          	ori	t2,t1,1
    8ffa:	00728623          	sb	t2,12(t0)
    8ffe:	8082                	ret
    9000:	460d                	li	a2,3
    9002:	04c59563          	bne	a1,a2,904c <ck_uart_set_wordsize+0x7c>
    9006:	6514                	ld	a3,8(a0)
    9008:	00c6c803          	lbu	a6,12(a3)
    900c:	00386893          	ori	a7,a6,3
    9010:	01168623          	sb	a7,12(a3)
    9014:	8082                	ret
    9016:	0001                	nop
    9018:	6518                	ld	a4,8(a0)
    901a:	00c74283          	lbu	t0,12(a4)
    901e:	0fe2f313          	andi	t1,t0,254
    9022:	00670623          	sb	t1,12(a4)
    9026:	00853383          	ld	t2,8(a0)
    902a:	00c3c503          	lbu	a0,12(t2)
    902e:	00256593          	ori	a1,a0,2
    9032:	00b38623          	sb	a1,12(t2)
    9036:	8082                	ret
    9038:	00853e03          	ld	t3,8(a0)
    903c:	00ce4e83          	lbu	t4,12(t3)
    9040:	0fceff13          	andi	t5,t4,252
    9044:	01ee0623          	sb	t5,12(t3)
    9048:	8082                	ret
    904a:	0001                	nop
    904c:	8082                	ret
    904e:	0001                	nop

0000000000009050 <ck_uart_set_stopbit>:
    9050:	cd0c                	sw	a1,24(a0)
    9052:	cd99                	beqz	a1,9070 <ck_uart_set_stopbit+0x20>
    9054:	4305                	li	t1,1
    9056:	00658363          	beq	a1,t1,905c <ck_uart_set_stopbit+0xc>
    905a:	8082                	ret
    905c:	00853383          	ld	t2,8(a0)
    9060:	00c3c503          	lbu	a0,12(t2)
    9064:	00456593          	ori	a1,a0,4
    9068:	00b38623          	sb	a1,12(t2)
    906c:	8082                	ret
    906e:	0001                	nop
    9070:	6518                	ld	a4,8(a0)
    9072:	00c74783          	lbu	a5,12(a4)
    9076:	0fb7f293          	andi	t0,a5,251
    907a:	00570623          	sb	t0,12(a4)
    907e:	8082                	ret

0000000000009080 <ck_uart_set_rxmode>:
    9080:	d10c                	sw	a1,32(a0)
    9082:	8082                	ret
    9084:	00000013          	nop
    9088:	00000013          	nop
    908c:	00000013          	nop

0000000000009090 <ck_uart_set_txmode>:
    9090:	d14c                	sw	a1,36(a0)
    9092:	8082                	ret
    9094:	00000013          	nop
    9098:	00000013          	nop
    909c:	00000013          	nop

00000000000090a0 <ck_uart_open>:
    90a0:	e981                	bnez	a1,90b0 <ck_uart_open+0x10>
    90a2:	100157b7          	lui	a5,0x10015
    90a6:	00052023          	sw	zero,0(a0)
    90aa:	e51c                	sd	a5,8(a0)
    90ac:	4501                	li	a0,0
    90ae:	8082                	ret
    90b0:	4505                	li	a0,1
    90b2:	8082                	ret
    90b4:	00000013          	nop
    90b8:	00000013          	nop
    90bc:	00000013          	nop

00000000000090c0 <ck_uart_init>:
    90c0:	4118                	lw	a4,0(a0)
    90c2:	67c1                	lui	a5,0x10
    90c4:	37fd                	addiw	a5,a5,-1 # ffff <_global_impure_ptr+0x586f>
    90c6:	0af70963          	beq	a4,a5,9178 <ck_uart_init+0xb8>
    90ca:	4194                	lw	a3,0(a1)
    90cc:	05f5e2b7          	lui	t0,0x5f5e
    90d0:	1002831b          	addiw	t1,t0,256 # 5f5e100 <__kernel_stack+0x5e70100>
    90d4:	02d353bb          	divuw	t2,t1,a3
    90d8:	6510                	ld	a2,8(a0)
    90da:	c914                	sw	a3,16(a0)
    90dc:	4705                	li	a4,1
    90de:	00c64803          	lbu	a6,12(a2)
    90e2:	08086893          	ori	a7,a6,128
    90e6:	01160623          	sb	a7,12(a2)
    90ea:	2c43be0b          	th.extu	t3,t2,11,4
    90ee:	01c60023          	sb	t3,0(a2)
    90f2:	4cc3be8b          	th.extu	t4,t2,19,12
    90f6:	01d60223          	sb	t4,4(a2)
    90fa:	00c64f03          	lbu	t5,12(a2)
    90fe:	07ff7f93          	andi	t6,t5,127
    9102:	01f60623          	sb	t6,12(a2)
    9106:	459c                	lw	a5,8(a1)
    9108:	c95c                	sw	a5,20(a0)
    910a:	0ce78b63          	beq	a5,a4,91e0 <ck_uart_init+0x120>
    910e:	4889                	li	a7,2
    9110:	11178e63          	beq	a5,a7,922c <ck_uart_init+0x16c>
    9114:	c7a5                	beqz	a5,917c <ck_uart_init+0xbc>
    9116:	45d0                	lw	a2,12(a1)
    9118:	4389                	li	t2,2
    911a:	cd50                	sw	a2,28(a0)
    911c:	06760d63          	beq	a2,t2,9196 <ck_uart_init+0xd6>
    9120:	0ec3ea63          	bltu	t2,a2,9214 <ck_uart_init+0x154>
    9124:	c265                	beqz	a2,9204 <ck_uart_init+0x144>
    9126:	00853803          	ld	a6,8(a0)
    912a:	00c84883          	lbu	a7,12(a6)
    912e:	0fd8fe13          	andi	t3,a7,253
    9132:	01c80623          	sb	t3,12(a6)
    9136:	00853e83          	ld	t4,8(a0)
    913a:	00cecf03          	lbu	t5,12(t4)
    913e:	001f6f93          	ori	t6,t5,1
    9142:	01fe8623          	sb	t6,12(t4)
    9146:	0045a283          	lw	t0,4(a1)
    914a:	00552c23          	sw	t0,24(a0)
    914e:	06028a63          	beqz	t0,91c2 <ck_uart_init+0x102>
    9152:	4685                	li	a3,1
    9154:	00d29a63          	bne	t0,a3,9168 <ck_uart_init+0xa8>
    9158:	00853383          	ld	t2,8(a0)
    915c:	00c3c603          	lbu	a2,12(t2)
    9160:	00466813          	ori	a6,a2,4
    9164:	01038623          	sb	a6,12(t2)
    9168:	0105a883          	lw	a7,16(a1)
    916c:	49cc                	lw	a1,20(a1)
    916e:	03152023          	sw	a7,32(a0)
    9172:	d14c                	sw	a1,36(a0)
    9174:	4501                	li	a0,0
    9176:	8082                	ret
    9178:	4505                	li	a0,1
    917a:	8082                	ret
    917c:	00853283          	ld	t0,8(a0)
    9180:	4389                	li	t2,2
    9182:	00c2c303          	lbu	t1,12(t0)
    9186:	0f737693          	andi	a3,t1,247
    918a:	00d28623          	sb	a3,12(t0)
    918e:	45d0                	lw	a2,12(a1)
    9190:	cd50                	sw	a2,28(a0)
    9192:	f87617e3          	bne	a2,t2,9120 <ck_uart_init+0x60>
    9196:	00853803          	ld	a6,8(a0)
    919a:	00c84883          	lbu	a7,12(a6)
    919e:	0fe8fe13          	andi	t3,a7,254
    91a2:	01c80623          	sb	t3,12(a6)
    91a6:	00853e83          	ld	t4,8(a0)
    91aa:	00cecf03          	lbu	t5,12(t4)
    91ae:	002f6f93          	ori	t6,t5,2
    91b2:	01fe8623          	sb	t6,12(t4)
    91b6:	0045a283          	lw	t0,4(a1)
    91ba:	00552c23          	sw	t0,24(a0)
    91be:	f8029ae3          	bnez	t0,9152 <ck_uart_init+0x92>
    91c2:	6518                	ld	a4,8(a0)
    91c4:	00c74783          	lbu	a5,12(a4)
    91c8:	0fb7f313          	andi	t1,a5,251
    91cc:	00670623          	sb	t1,12(a4)
    91d0:	0105a883          	lw	a7,16(a1)
    91d4:	49cc                	lw	a1,20(a1)
    91d6:	03152023          	sw	a7,32(a0)
    91da:	d14c                	sw	a1,36(a0)
    91dc:	4501                	li	a0,0
    91de:	8082                	ret
    91e0:	00853283          	ld	t0,8(a0)
    91e4:	00c2c303          	lbu	t1,12(t0)
    91e8:	00836693          	ori	a3,t1,8
    91ec:	00d28623          	sb	a3,12(t0)
    91f0:	00853383          	ld	t2,8(a0)
    91f4:	00c3c603          	lbu	a2,12(t2)
    91f8:	0ef67813          	andi	a6,a2,239
    91fc:	01038623          	sb	a6,12(t2)
    9200:	bf19                	j	9116 <ck_uart_init+0x56>
    9202:	0001                	nop
    9204:	6514                	ld	a3,8(a0)
    9206:	00c6c383          	lbu	t2,12(a3)
    920a:	0fc3f613          	andi	a2,t2,252
    920e:	00c68623          	sb	a2,12(a3)
    9212:	bf15                	j	9146 <ck_uart_init+0x86>
    9214:	470d                	li	a4,3
    9216:	f2e618e3          	bne	a2,a4,9146 <ck_uart_init+0x86>
    921a:	00853283          	ld	t0,8(a0)
    921e:	00c2c783          	lbu	a5,12(t0)
    9222:	0037e313          	ori	t1,a5,3
    9226:	00628623          	sb	t1,12(t0)
    922a:	bf31                	j	9146 <ck_uart_init+0x86>
    922c:	00853e03          	ld	t3,8(a0)
    9230:	00ce4e83          	lbu	t4,12(t3)
    9234:	008eef13          	ori	t5,t4,8
    9238:	01ee0623          	sb	t5,12(t3)
    923c:	00853f83          	ld	t6,8(a0)
    9240:	00cfc703          	lbu	a4,12(t6)
    9244:	01076793          	ori	a5,a4,16
    9248:	00ff8623          	sb	a5,12(t6)
    924c:	b5e9                	j	9116 <ck_uart_init+0x56>
    924e:	0001                	nop

0000000000009250 <ck_uart_close>:
    9250:	67c1                	lui	a5,0x10
    9252:	37fd                	addiw	a5,a5,-1 # ffff <_global_impure_ptr+0x586f>
    9254:	c11c                	sw	a5,0(a0)
    9256:	02053023          	sd	zero,32(a0)
    925a:	4501                	li	a0,0
    925c:	8082                	ret
    925e:	0001                	nop

0000000000009260 <ck_uart_putc>:
    9260:	515c                	lw	a5,36(a0)
    9262:	c7ad                	beqz	a5,92cc <ck_uart_putc+0x6c>
    9264:	00853283          	ld	t0,8(a0)
    9268:	0142c703          	lbu	a4,20(t0)
    926c:	02077313          	andi	t1,a4,32
    9270:	04031963          	bnez	t1,92c2 <ck_uart_putc+0x62>
    9274:	0142c383          	lbu	t2,20(t0)
    9278:	0203f513          	andi	a0,t2,32
    927c:	e139                	bnez	a0,92c2 <ck_uart_putc+0x62>
    927e:	0142c603          	lbu	a2,20(t0)
    9282:	02067693          	andi	a3,a2,32
    9286:	ee95                	bnez	a3,92c2 <ck_uart_putc+0x62>
    9288:	0142c803          	lbu	a6,20(t0)
    928c:	02087893          	andi	a7,a6,32
    9290:	02089963          	bnez	a7,92c2 <ck_uart_putc+0x62>
    9294:	0142ce03          	lbu	t3,20(t0)
    9298:	020e7e93          	andi	t4,t3,32
    929c:	020e9363          	bnez	t4,92c2 <ck_uart_putc+0x62>
    92a0:	0142cf03          	lbu	t5,20(t0)
    92a4:	020f7f93          	andi	t6,t5,32
    92a8:	000f9d63          	bnez	t6,92c2 <ck_uart_putc+0x62>
    92ac:	0142c783          	lbu	a5,20(t0)
    92b0:	0207f713          	andi	a4,a5,32
    92b4:	e719                	bnez	a4,92c2 <ck_uart_putc+0x62>
    92b6:	0142c303          	lbu	t1,20(t0)
    92ba:	02037393          	andi	t2,t1,32
    92be:	fa0385e3          	beqz	t2,9268 <ck_uart_putc+0x8>
    92c2:	00b28023          	sb	a1,0(t0)
    92c6:	4501                	li	a0,0
    92c8:	8082                	ret
    92ca:	0001                	nop
    92cc:	4505                	li	a0,1
    92ce:	8082                	ret

00000000000092d0 <ck_uart_status>:
    92d0:	4505                	li	a0,1
    92d2:	8082                	ret
	...

00000000000092e0 <vasprintf>:
    92e0:	7139                	addi	sp,sp,-64
    92e2:	f9515b0b          	th.sdd	s6,s5,(sp),0,4
    92e6:	8b2a                	mv	s6,a0
    92e8:	852e                	mv	a0,a1
    92ea:	fb315a0b          	th.sdd	s4,s3,(sp),1,4
    92ee:	fc91590b          	th.sdd	s2,s1,(sp),2,4
    92f2:	fe11540b          	th.sdd	s0,ra,(sp),3,4
    92f6:	8a2e                	mv	s4,a1
    92f8:	8ab2                	mv	s5,a2
    92fa:	197000ef          	jal	9c90 <strlen>
    92fe:	00150993          	addi	s3,a0,1
    9302:	f009f293          	andi	t0,s3,-256
    9306:	10028913          	addi	s2,t0,256
    930a:	20028993          	addi	s3,t0,512
    930e:	000b3023          	sd	zero,0(s6)
    9312:	0001                	nop
    9314:	00000013          	nop
    9318:	854a                	mv	a0,s2
    931a:	17c000ef          	jal	9496 <malloc>
    931e:	84aa                	mv	s1,a0
    9320:	c525                	beqz	a0,9388 <vasprintf+0xa8>
    9322:	86d6                	mv	a3,s5
    9324:	8652                	mv	a2,s4
    9326:	85ca                	mv	a1,s2
    9328:	ba9ff0ef          	jal	8ed0 <vsnprintf>
    932c:	842a                	mv	s0,a0
    932e:	00054f63          	bltz	a0,934c <vasprintf+0x6c>
    9332:	197d                	addi	s2,s2,-1
    9334:	03256463          	bltu	a0,s2,935c <vasprintf+0x7c>
    9338:	8526                	mv	a0,s1
    933a:	168000ef          	jal	94a2 <free>
    933e:	01346a63          	bltu	s0,s3,9352 <vasprintf+0x72>
    9342:	0014091b          	addiw	s2,s0,1
    9346:	10098993          	addi	s3,s3,256
    934a:	b7f9                	j	9318 <vasprintf+0x38>
    934c:	8526                	mv	a0,s1
    934e:	154000ef          	jal	94a2 <free>
    9352:	894e                	mv	s2,s3
    9354:	10098993          	addi	s3,s3,256
    9358:	b7c1                	j	9318 <vasprintf+0x38>
    935a:	0001                	nop
    935c:	ed01                	bnez	a0,9374 <vasprintf+0x94>
    935e:	8522                	mv	a0,s0
    9360:	fe11440b          	th.ldd	s0,ra,(sp),3,4
    9364:	fc91490b          	th.ldd	s2,s1,(sp),2,4
    9368:	fb314a0b          	th.ldd	s4,s3,(sp),1,4
    936c:	f9514b0b          	th.ldd	s6,s5,(sp),0,4
    9370:	6121                	addi	sp,sp,64
    9372:	8082                	ret
    9374:	8526                	mv	a0,s1
    9376:	0d5000ef          	jal	9c4a <strdup>
    937a:	c909                	beqz	a0,938c <vasprintf+0xac>
    937c:	00ab3023          	sd	a0,0(s6)
    9380:	8526                	mv	a0,s1
    9382:	120000ef          	jal	94a2 <free>
    9386:	bfe1                	j	935e <vasprintf+0x7e>
    9388:	5451                	li	s0,-12
    938a:	bfd1                	j	935e <vasprintf+0x7e>
    938c:	009b3023          	sd	s1,0(s6)
    9390:	b7f9                	j	935e <vasprintf+0x7e>
    9392:	0001                	nop
    9394:	00000013          	nop
    9398:	00000013          	nop
    939c:	00000013          	nop

00000000000093a0 <asprintf>:
    93a0:	7119                	addi	sp,sp,-128
    93a2:	fb515b0b          	th.sdd	s6,s5,(sp),1,4
    93a6:	8b2a                	mv	s6,a0
    93a8:	05010a93          	addi	s5,sp,80
    93ac:	852e                	mv	a0,a1
    93ae:	fd315a0b          	th.sdd	s4,s3,(sp),2,4
    93b2:	fe91590b          	th.sdd	s2,s1,(sp),3,4
    93b6:	e0a2                	sd	s0,64(sp)
    93b8:	e486                	sd	ra,72(sp)
    93ba:	e8b2                	sd	a2,80(sp)
    93bc:	ecb6                	sd	a3,88(sp)
    93be:	f0ba                	sd	a4,96(sp)
    93c0:	f4be                	sd	a5,104(sp)
    93c2:	f8c2                	sd	a6,112(sp)
    93c4:	fcc6                	sd	a7,120(sp)
    93c6:	8a2e                	mv	s4,a1
    93c8:	e456                	sd	s5,8(sp)
    93ca:	0c7000ef          	jal	9c90 <strlen>
    93ce:	00150993          	addi	s3,a0,1
    93d2:	f009f293          	andi	t0,s3,-256
    93d6:	10028913          	addi	s2,t0,256
    93da:	20028993          	addi	s3,t0,512
    93de:	000b3023          	sd	zero,0(s6)
    93e2:	0001                	nop
    93e4:	00000013          	nop
    93e8:	854a                	mv	a0,s2
    93ea:	0ac000ef          	jal	9496 <malloc>
    93ee:	84aa                	mv	s1,a0
    93f0:	c525                	beqz	a0,9458 <asprintf+0xb8>
    93f2:	86d6                	mv	a3,s5
    93f4:	8652                	mv	a2,s4
    93f6:	85ca                	mv	a1,s2
    93f8:	ad9ff0ef          	jal	8ed0 <vsnprintf>
    93fc:	842a                	mv	s0,a0
    93fe:	00054f63          	bltz	a0,941c <asprintf+0x7c>
    9402:	197d                	addi	s2,s2,-1
    9404:	03256463          	bltu	a0,s2,942c <asprintf+0x8c>
    9408:	8526                	mv	a0,s1
    940a:	098000ef          	jal	94a2 <free>
    940e:	01346a63          	bltu	s0,s3,9422 <asprintf+0x82>
    9412:	0014091b          	addiw	s2,s0,1
    9416:	10098993          	addi	s3,s3,256
    941a:	b7f9                	j	93e8 <asprintf+0x48>
    941c:	8526                	mv	a0,s1
    941e:	084000ef          	jal	94a2 <free>
    9422:	894e                	mv	s2,s3
    9424:	10098993          	addi	s3,s3,256
    9428:	b7c1                	j	93e8 <asprintf+0x48>
    942a:	0001                	nop
    942c:	ed01                	bnez	a0,9444 <asprintf+0xa4>
    942e:	8522                	mv	a0,s0
    9430:	6406                	ld	s0,64(sp)
    9432:	60a6                	ld	ra,72(sp)
    9434:	fe91490b          	th.ldd	s2,s1,(sp),3,4
    9438:	fd314a0b          	th.ldd	s4,s3,(sp),2,4
    943c:	fb514b0b          	th.ldd	s6,s5,(sp),1,4
    9440:	6109                	addi	sp,sp,128
    9442:	8082                	ret
    9444:	8526                	mv	a0,s1
    9446:	005000ef          	jal	9c4a <strdup>
    944a:	c909                	beqz	a0,945c <asprintf+0xbc>
    944c:	00ab3023          	sd	a0,0(s6)
    9450:	8526                	mv	a0,s1
    9452:	050000ef          	jal	94a2 <free>
    9456:	bfe1                	j	942e <asprintf+0x8e>
    9458:	5451                	li	s0,-12
    945a:	bfd1                	j	942e <asprintf+0x8e>
    945c:	009b3023          	sd	s1,0(s6)
    9460:	b7f9                	j	942e <asprintf+0x8e>
	...

0000000000009470 <get_vtimer>:
    9470:	1141                	addi	sp,sp,-16
    9472:	c01027f3          	rdtime	a5
    9476:	c63e                	sw	a5,12(sp)
    9478:	4532                	lw	a0,12(sp)
    947a:	0141                	addi	sp,sp,16
    947c:	8082                	ret
    947e:	0001                	nop

0000000000009480 <sim_end>:
    9480:	050017b7          	lui	a5,0x5001
    9484:	44333737          	lui	a4,0x44333
    9488:	00579293          	slli	t0,a5,0x5
    948c:	22270313          	addi	t1,a4,546 # 44333222 <__kernel_stack+0x44245222>
    9490:	f462a423          	sw	t1,-184(t0)
    9494:	8082                	ret

0000000000009496 <malloc>:
    9496:	85aa                	mv	a1,a0
    9498:	00038517          	auipc	a0,0x38
    949c:	af053503          	ld	a0,-1296(a0) # 40f88 <_impure_ptr>
    94a0:	a801                	j	94b0 <_malloc_r>

00000000000094a2 <free>:
    94a2:	85aa                	mv	a1,a0
    94a4:	00038517          	auipc	a0,0x38
    94a8:	ae453503          	ld	a0,-1308(a0) # 40f88 <_impure_ptr>
    94ac:	15d0006f          	j	9e08 <_free_r>

00000000000094b0 <_malloc_r>:
    94b0:	711d                	addi	sp,sp,-96
    94b2:	e4a6                	sd	s1,72(sp)
    94b4:	e0ca                	sd	s2,64(sp)
    94b6:	ec86                	sd	ra,88(sp)
    94b8:	e8a2                	sd	s0,80(sp)
    94ba:	fc4e                	sd	s3,56(sp)
    94bc:	01758493          	addi	s1,a1,23
    94c0:	02e00793          	li	a5,46
    94c4:	892a                	mv	s2,a0
    94c6:	0497ec63          	bltu	a5,s1,951e <_malloc_r+0x6e>
    94ca:	02000493          	li	s1,32
    94ce:	18b4eb63          	bltu	s1,a1,9664 <_malloc_r+0x1b4>
    94d2:	63c000ef          	jal	9b0e <__malloc_lock>
    94d6:	05000793          	li	a5,80
    94da:	4591                	li	a1,4
    94dc:	00037997          	auipc	s3,0x37
    94e0:	b2c98993          	addi	s3,s3,-1236 # 40008 <__malloc_av_>
    94e4:	97ce                	add	a5,a5,s3
    94e6:	6780                	ld	s0,8(a5)
    94e8:	ff078713          	addi	a4,a5,-16 # 5000ff0 <__kernel_stack+0x4f12ff0>
    94ec:	34e40b63          	beq	s0,a4,9842 <_malloc_r+0x392>
    94f0:	641c                	ld	a5,8(s0)
    94f2:	6c14                	ld	a3,24(s0)
    94f4:	6810                	ld	a2,16(s0)
    94f6:	9bf1                	andi	a5,a5,-4
    94f8:	97a2                	add	a5,a5,s0
    94fa:	6798                	ld	a4,8(a5)
    94fc:	ee14                	sd	a3,24(a2)
    94fe:	ea90                	sd	a2,16(a3)
    9500:	00176713          	ori	a4,a4,1
    9504:	854a                	mv	a0,s2
    9506:	e798                	sd	a4,8(a5)
    9508:	612000ef          	jal	9b1a <__malloc_unlock>
    950c:	60e6                	ld	ra,88(sp)
    950e:	01040513          	addi	a0,s0,16
    9512:	6446                	ld	s0,80(sp)
    9514:	64a6                	ld	s1,72(sp)
    9516:	6906                	ld	s2,64(sp)
    9518:	79e2                	ld	s3,56(sp)
    951a:	6125                	addi	sp,sp,96
    951c:	8082                	ret
    951e:	800007b7          	lui	a5,0x80000
    9522:	98c1                	andi	s1,s1,-16
    9524:	fff7c793          	not	a5,a5
    9528:	1297ee63          	bltu	a5,s1,9664 <_malloc_r+0x1b4>
    952c:	12b4ec63          	bltu	s1,a1,9664 <_malloc_r+0x1b4>
    9530:	5de000ef          	jal	9b0e <__malloc_lock>
    9534:	1f700793          	li	a5,503
    9538:	4097f063          	bgeu	a5,s1,9938 <_malloc_r+0x488>
    953c:	0094d793          	srli	a5,s1,0x9
    9540:	12078d63          	beqz	a5,967a <_malloc_r+0x1ca>
    9544:	4711                	li	a4,4
    9546:	34f76563          	bltu	a4,a5,9890 <_malloc_r+0x3e0>
    954a:	0064d793          	srli	a5,s1,0x6
    954e:	0397859b          	addiw	a1,a5,57 # ffffffff80000039 <__kernel_stack+0xffffffff7ff12039>
    9552:	0015961b          	slliw	a2,a1,0x1
    9556:	0387881b          	addiw	a6,a5,56
    955a:	060e                	slli	a2,a2,0x3
    955c:	00037997          	auipc	s3,0x37
    9560:	aac98993          	addi	s3,s3,-1364 # 40008 <__malloc_av_>
    9564:	964e                	add	a2,a2,s3
    9566:	6600                	ld	s0,8(a2)
    9568:	1641                	addi	a2,a2,-16
    956a:	02860163          	beq	a2,s0,958c <_malloc_r+0xdc>
    956e:	457d                	li	a0,31
    9570:	a039                	j	957e <_malloc_r+0xce>
    9572:	6c14                	ld	a3,24(s0)
    9574:	2a075363          	bgez	a4,981a <_malloc_r+0x36a>
    9578:	00d60a63          	beq	a2,a3,958c <_malloc_r+0xdc>
    957c:	8436                	mv	s0,a3
    957e:	641c                	ld	a5,8(s0)
    9580:	9bf1                	andi	a5,a5,-4
    9582:	40978733          	sub	a4,a5,s1
    9586:	fee556e3          	bge	a0,a4,9572 <_malloc_r+0xc2>
    958a:	85c2                	mv	a1,a6
    958c:	0209b403          	ld	s0,32(s3)
    9590:	00037897          	auipc	a7,0x37
    9594:	a8888893          	addi	a7,a7,-1400 # 40018 <__malloc_av_+0x10>
    9598:	27140e63          	beq	s0,a7,9814 <_malloc_r+0x364>
    959c:	641c                	ld	a5,8(s0)
    959e:	46fd                	li	a3,31
    95a0:	9bf1                	andi	a5,a5,-4
    95a2:	40978733          	sub	a4,a5,s1
    95a6:	36e6c263          	blt	a3,a4,990a <_malloc_r+0x45a>
    95aa:	0319b423          	sd	a7,40(s3)
    95ae:	0319b023          	sd	a7,32(s3)
    95b2:	34075163          	bgez	a4,98f4 <_malloc_r+0x444>
    95b6:	1ff00713          	li	a4,511
    95ba:	0089b503          	ld	a0,8(s3)
    95be:	28f76763          	bltu	a4,a5,984c <_malloc_r+0x39c>
    95c2:	838d                	srli	a5,a5,0x3
    95c4:	2781                	sext.w	a5,a5
    95c6:	0017871b          	addiw	a4,a5,1
    95ca:	0017171b          	slliw	a4,a4,0x1
    95ce:	070e                	slli	a4,a4,0x3
    95d0:	974e                	add	a4,a4,s3
    95d2:	6310                	ld	a2,0(a4)
    95d4:	4027d79b          	sraiw	a5,a5,0x2
    95d8:	4685                	li	a3,1
    95da:	00f697b3          	sll	a5,a3,a5
    95de:	8d5d                	or	a0,a0,a5
    95e0:	ff070793          	addi	a5,a4,-16
    95e4:	e810                	sd	a2,16(s0)
    95e6:	ec1c                	sd	a5,24(s0)
    95e8:	00a9b423          	sd	a0,8(s3)
    95ec:	e300                	sd	s0,0(a4)
    95ee:	ee00                	sd	s0,24(a2)
    95f0:	4025d79b          	sraiw	a5,a1,0x2
    95f4:	4605                	li	a2,1
    95f6:	00f61633          	sll	a2,a2,a5
    95fa:	08c56763          	bltu	a0,a2,9688 <_malloc_r+0x1d8>
    95fe:	00a677b3          	and	a5,a2,a0
    9602:	ef81                	bnez	a5,961a <_malloc_r+0x16a>
    9604:	0606                	slli	a2,a2,0x1
    9606:	99f1                	andi	a1,a1,-4
    9608:	00a677b3          	and	a5,a2,a0
    960c:	2591                	addiw	a1,a1,4
    960e:	e791                	bnez	a5,961a <_malloc_r+0x16a>
    9610:	0606                	slli	a2,a2,0x1
    9612:	00a677b3          	and	a5,a2,a0
    9616:	2591                	addiw	a1,a1,4
    9618:	dfe5                	beqz	a5,9610 <_malloc_r+0x160>
    961a:	487d                	li	a6,31
    961c:	0015831b          	addiw	t1,a1,1
    9620:	0013131b          	slliw	t1,t1,0x1
    9624:	030e                	slli	t1,t1,0x3
    9626:	1341                	addi	t1,t1,-16
    9628:	934e                	add	t1,t1,s3
    962a:	851a                	mv	a0,t1
    962c:	6d1c                	ld	a5,24(a0)
    962e:	8e2e                	mv	t3,a1
    9630:	28f50163          	beq	a0,a5,98b2 <_malloc_r+0x402>
    9634:	6798                	ld	a4,8(a5)
    9636:	843e                	mv	s0,a5
    9638:	6f9c                	ld	a5,24(a5)
    963a:	9b71                	andi	a4,a4,-4
    963c:	409706b3          	sub	a3,a4,s1
    9640:	28d84063          	blt	a6,a3,98c0 <_malloc_r+0x410>
    9644:	fe06c6e3          	bltz	a3,9630 <_malloc_r+0x180>
    9648:	9722                	add	a4,a4,s0
    964a:	6714                	ld	a3,8(a4)
    964c:	6810                	ld	a2,16(s0)
    964e:	854a                	mv	a0,s2
    9650:	0016e693          	ori	a3,a3,1
    9654:	e714                	sd	a3,8(a4)
    9656:	ee1c                	sd	a5,24(a2)
    9658:	eb90                	sd	a2,16(a5)
    965a:	4c0000ef          	jal	9b1a <__malloc_unlock>
    965e:	01040513          	addi	a0,s0,16
    9662:	a029                	j	966c <_malloc_r+0x1bc>
    9664:	47b1                	li	a5,12
    9666:	00f92023          	sw	a5,0(s2)
    966a:	4501                	li	a0,0
    966c:	60e6                	ld	ra,88(sp)
    966e:	6446                	ld	s0,80(sp)
    9670:	64a6                	ld	s1,72(sp)
    9672:	6906                	ld	s2,64(sp)
    9674:	79e2                	ld	s3,56(sp)
    9676:	6125                	addi	sp,sp,96
    9678:	8082                	ret
    967a:	40000613          	li	a2,1024
    967e:	04000593          	li	a1,64
    9682:	03f00813          	li	a6,63
    9686:	bdd9                	j	955c <_malloc_r+0xac>
    9688:	0109b403          	ld	s0,16(s3)
    968c:	f456                	sd	s5,40(sp)
    968e:	641c                	ld	a5,8(s0)
    9690:	ffc7fa93          	andi	s5,a5,-4
    9694:	009ae763          	bltu	s5,s1,96a2 <_malloc_r+0x1f2>
    9698:	409a8733          	sub	a4,s5,s1
    969c:	47fd                	li	a5,31
    969e:	14e7c563          	blt	a5,a4,97e8 <_malloc_r+0x338>
    96a2:	e862                	sd	s8,16(sp)
    96a4:	00038c17          	auipc	s8,0x38
    96a8:	8d4c0c13          	addi	s8,s8,-1836 # 40f78 <__malloc_sbrk_base>
    96ac:	f852                	sd	s4,48(sp)
    96ae:	000c3703          	ld	a4,0(s8)
    96b2:	0003aa17          	auipc	s4,0x3a
    96b6:	1aea3a03          	ld	s4,430(s4) # 43860 <__malloc_top_pad>
    96ba:	ec5e                	sd	s7,24(sp)
    96bc:	f05a                	sd	s6,32(sp)
    96be:	57fd                	li	a5,-1
    96c0:	01540bb3          	add	s7,s0,s5
    96c4:	9a26                	add	s4,s4,s1
    96c6:	2ef70f63          	beq	a4,a5,99c4 <_malloc_r+0x514>
    96ca:	6785                	lui	a5,0x1
    96cc:	07fd                	addi	a5,a5,31 # 101f <_ftoa+0x19f>
    96ce:	9a3e                	add	s4,s4,a5
    96d0:	77fd                	lui	a5,0xfffff
    96d2:	00fa7a33          	and	s4,s4,a5
    96d6:	85d2                	mv	a1,s4
    96d8:	854a                	mv	a0,s2
    96da:	44c000ef          	jal	9b26 <_sbrk_r>
    96de:	57fd                	li	a5,-1
    96e0:	8b2a                	mv	s6,a0
    96e2:	38f50363          	beq	a0,a5,9a68 <_malloc_r+0x5b8>
    96e6:	e466                	sd	s9,8(sp)
    96e8:	0d756e63          	bltu	a0,s7,97c4 <_malloc_r+0x314>
    96ec:	0003a717          	auipc	a4,0x3a
    96f0:	13c72703          	lw	a4,316(a4) # 43828 <__malloc_current_mallinfo>
    96f4:	0003ac97          	auipc	s9,0x3a
    96f8:	134c8c93          	addi	s9,s9,308 # 43828 <__malloc_current_mallinfo>
    96fc:	0147073b          	addw	a4,a4,s4
    9700:	00eca023          	sw	a4,0(s9)
    9704:	86ba                	mv	a3,a4
    9706:	36ab8563          	beq	s7,a0,9a70 <_malloc_r+0x5c0>
    970a:	000c3703          	ld	a4,0(s8)
    970e:	57fd                	li	a5,-1
    9710:	36f70d63          	beq	a4,a5,9a8a <_malloc_r+0x5da>
    9714:	417b07b3          	sub	a5,s6,s7
    9718:	9fb5                	addw	a5,a5,a3
    971a:	00fca023          	sw	a5,0(s9)
    971e:	00fb7c13          	andi	s8,s6,15
    9722:	2a0c0d63          	beqz	s8,99dc <_malloc_r+0x52c>
    9726:	418b0b33          	sub	s6,s6,s8
    972a:	6685                	lui	a3,0x1
    972c:	0b41                	addi	s6,s6,16
    972e:	06c1                	addi	a3,a3,16 # 1010 <_ftoa+0x190>
    9730:	9a5a                	add	s4,s4,s6
    9732:	418686b3          	sub	a3,a3,s8
    9736:	414686b3          	sub	a3,a3,s4
    973a:	16d2                	slli	a3,a3,0x34
    973c:	0346db93          	srli	s7,a3,0x34
    9740:	85de                	mv	a1,s7
    9742:	854a                	mv	a0,s2
    9744:	3e2000ef          	jal	9b26 <_sbrk_r>
    9748:	57fd                	li	a5,-1
    974a:	36f50f63          	beq	a0,a5,9ac8 <_malloc_r+0x618>
    974e:	41650533          	sub	a0,a0,s6
    9752:	01750a33          	add	s4,a0,s7
    9756:	000b869b          	sext.w	a3,s7
    975a:	0003a717          	auipc	a4,0x3a
    975e:	0ce72703          	lw	a4,206(a4) # 43828 <__malloc_current_mallinfo>
    9762:	0169b823          	sd	s6,16(s3)
    9766:	001a6793          	ori	a5,s4,1
    976a:	9f35                	addw	a4,a4,a3
    976c:	00fb3423          	sd	a5,8(s6)
    9770:	00eca023          	sw	a4,0(s9)
    9774:	03340563          	beq	s0,s3,979e <_malloc_r+0x2ee>
    9778:	467d                	li	a2,31
    977a:	29567163          	bgeu	a2,s5,99fc <_malloc_r+0x54c>
    977e:	6414                	ld	a3,8(s0)
    9780:	fe8a8793          	addi	a5,s5,-24
    9784:	9bc1                	andi	a5,a5,-16
    9786:	8a85                	andi	a3,a3,1
    9788:	8edd                	or	a3,a3,a5
    978a:	e414                	sd	a3,8(s0)
    978c:	45a5                	li	a1,9
    978e:	00f406b3          	add	a3,s0,a5
    9792:	e68c                	sd	a1,8(a3)
    9794:	ea8c                	sd	a1,16(a3)
    9796:	20f66b63          	bltu	a2,a5,99ac <_malloc_r+0x4fc>
    979a:	008b3783          	ld	a5,8(s6)
    979e:	0003a697          	auipc	a3,0x3a
    97a2:	0ba68693          	addi	a3,a3,186 # 43858 <__malloc_max_sbrked_mem>
    97a6:	6290                	ld	a2,0(a3)
    97a8:	00e67363          	bgeu	a2,a4,97ae <_malloc_r+0x2fe>
    97ac:	e298                	sd	a4,0(a3)
    97ae:	0003a697          	auipc	a3,0x3a
    97b2:	0a268693          	addi	a3,a3,162 # 43850 <__malloc_max_total_mem>
    97b6:	6290                	ld	a2,0(a3)
    97b8:	00e67363          	bgeu	a2,a4,97be <_malloc_r+0x30e>
    97bc:	e298                	sd	a4,0(a3)
    97be:	6ca2                	ld	s9,8(sp)
    97c0:	845a                	mv	s0,s6
    97c2:	a039                	j	97d0 <_malloc_r+0x320>
    97c4:	29340563          	beq	s0,s3,9a4e <_malloc_r+0x59e>
    97c8:	0109b403          	ld	s0,16(s3)
    97cc:	6ca2                	ld	s9,8(sp)
    97ce:	641c                	ld	a5,8(s0)
    97d0:	9bf1                	andi	a5,a5,-4
    97d2:	40978733          	sub	a4,a5,s1
    97d6:	2297e763          	bltu	a5,s1,9a04 <_malloc_r+0x554>
    97da:	47fd                	li	a5,31
    97dc:	22e7d463          	bge	a5,a4,9a04 <_malloc_r+0x554>
    97e0:	7a42                	ld	s4,48(sp)
    97e2:	7b02                	ld	s6,32(sp)
    97e4:	6be2                	ld	s7,24(sp)
    97e6:	6c42                	ld	s8,16(sp)
    97e8:	0014e793          	ori	a5,s1,1
    97ec:	e41c                	sd	a5,8(s0)
    97ee:	94a2                	add	s1,s1,s0
    97f0:	0099b823          	sd	s1,16(s3)
    97f4:	00176713          	ori	a4,a4,1
    97f8:	854a                	mv	a0,s2
    97fa:	e498                	sd	a4,8(s1)
    97fc:	31e000ef          	jal	9b1a <__malloc_unlock>
    9800:	60e6                	ld	ra,88(sp)
    9802:	01040513          	addi	a0,s0,16
    9806:	6446                	ld	s0,80(sp)
    9808:	7aa2                	ld	s5,40(sp)
    980a:	64a6                	ld	s1,72(sp)
    980c:	6906                	ld	s2,64(sp)
    980e:	79e2                	ld	s3,56(sp)
    9810:	6125                	addi	sp,sp,96
    9812:	8082                	ret
    9814:	0089b503          	ld	a0,8(s3)
    9818:	bbe1                	j	95f0 <_malloc_r+0x140>
    981a:	6810                	ld	a2,16(s0)
    981c:	97a2                	add	a5,a5,s0
    981e:	6798                	ld	a4,8(a5)
    9820:	ee14                	sd	a3,24(a2)
    9822:	ea90                	sd	a2,16(a3)
    9824:	00176713          	ori	a4,a4,1
    9828:	854a                	mv	a0,s2
    982a:	e798                	sd	a4,8(a5)
    982c:	2ee000ef          	jal	9b1a <__malloc_unlock>
    9830:	60e6                	ld	ra,88(sp)
    9832:	01040513          	addi	a0,s0,16
    9836:	6446                	ld	s0,80(sp)
    9838:	64a6                	ld	s1,72(sp)
    983a:	6906                	ld	s2,64(sp)
    983c:	79e2                	ld	s3,56(sp)
    983e:	6125                	addi	sp,sp,96
    9840:	8082                	ret
    9842:	6f80                	ld	s0,24(a5)
    9844:	2589                	addiw	a1,a1,2
    9846:	d48783e3          	beq	a5,s0,958c <_malloc_r+0xdc>
    984a:	b15d                	j	94f0 <_malloc_r+0x40>
    984c:	0097d713          	srli	a4,a5,0x9
    9850:	4691                	li	a3,4
    9852:	0ee6fc63          	bgeu	a3,a4,994a <_malloc_r+0x49a>
    9856:	46d1                	li	a3,20
    9858:	1ae6ef63          	bltu	a3,a4,9a16 <_malloc_r+0x566>
    985c:	05c7061b          	addiw	a2,a4,92
    9860:	0016161b          	slliw	a2,a2,0x1
    9864:	060e                	slli	a2,a2,0x3
    9866:	05b7069b          	addiw	a3,a4,91
    986a:	964e                	add	a2,a2,s3
    986c:	6218                	ld	a4,0(a2)
    986e:	1641                	addi	a2,a2,-16
    9870:	00e61663          	bne	a2,a4,987c <_malloc_r+0x3cc>
    9874:	aa99                	j	99ca <_malloc_r+0x51a>
    9876:	6b18                	ld	a4,16(a4)
    9878:	00e60663          	beq	a2,a4,9884 <_malloc_r+0x3d4>
    987c:	6714                	ld	a3,8(a4)
    987e:	9af1                	andi	a3,a3,-4
    9880:	fed7ebe3          	bltu	a5,a3,9876 <_malloc_r+0x3c6>
    9884:	6f10                	ld	a2,24(a4)
    9886:	ec10                	sd	a2,24(s0)
    9888:	e818                	sd	a4,16(s0)
    988a:	ea00                	sd	s0,16(a2)
    988c:	ef00                	sd	s0,24(a4)
    988e:	b38d                	j	95f0 <_malloc_r+0x140>
    9890:	4751                	li	a4,20
    9892:	0cf77663          	bgeu	a4,a5,995e <_malloc_r+0x4ae>
    9896:	05400713          	li	a4,84
    989a:	18f76c63          	bltu	a4,a5,9a32 <_malloc_r+0x582>
    989e:	00c4d793          	srli	a5,s1,0xc
    98a2:	06f7859b          	addiw	a1,a5,111 # fffffffffffff06f <__kernel_stack+0xfffffffffff1106f>
    98a6:	0015961b          	slliw	a2,a1,0x1
    98aa:	06e7881b          	addiw	a6,a5,110
    98ae:	060e                	slli	a2,a2,0x3
    98b0:	b175                	j	955c <_malloc_r+0xac>
    98b2:	2e05                	addiw	t3,t3,1
    98b4:	003e7793          	andi	a5,t3,3
    98b8:	0541                	addi	a0,a0,16
    98ba:	cfdd                	beqz	a5,9978 <_malloc_r+0x4c8>
    98bc:	6d1c                	ld	a5,24(a0)
    98be:	bb8d                	j	9630 <_malloc_r+0x180>
    98c0:	6810                	ld	a2,16(s0)
    98c2:	0014e593          	ori	a1,s1,1
    98c6:	e40c                	sd	a1,8(s0)
    98c8:	ee1c                	sd	a5,24(a2)
    98ca:	eb90                	sd	a2,16(a5)
    98cc:	94a2                	add	s1,s1,s0
    98ce:	0299b423          	sd	s1,40(s3)
    98d2:	0299b023          	sd	s1,32(s3)
    98d6:	0016e793          	ori	a5,a3,1
    98da:	9722                	add	a4,a4,s0
    98dc:	0114bc23          	sd	a7,24(s1)
    98e0:	0114b823          	sd	a7,16(s1)
    98e4:	e49c                	sd	a5,8(s1)
    98e6:	854a                	mv	a0,s2
    98e8:	e314                	sd	a3,0(a4)
    98ea:	230000ef          	jal	9b1a <__malloc_unlock>
    98ee:	01040513          	addi	a0,s0,16
    98f2:	bbad                	j	966c <_malloc_r+0x1bc>
    98f4:	97a2                	add	a5,a5,s0
    98f6:	6798                	ld	a4,8(a5)
    98f8:	854a                	mv	a0,s2
    98fa:	00176713          	ori	a4,a4,1
    98fe:	e798                	sd	a4,8(a5)
    9900:	21a000ef          	jal	9b1a <__malloc_unlock>
    9904:	01040513          	addi	a0,s0,16
    9908:	b395                	j	966c <_malloc_r+0x1bc>
    990a:	0014e693          	ori	a3,s1,1
    990e:	e414                	sd	a3,8(s0)
    9910:	94a2                	add	s1,s1,s0
    9912:	0299b423          	sd	s1,40(s3)
    9916:	0299b023          	sd	s1,32(s3)
    991a:	00176693          	ori	a3,a4,1
    991e:	97a2                	add	a5,a5,s0
    9920:	0114bc23          	sd	a7,24(s1)
    9924:	0114b823          	sd	a7,16(s1)
    9928:	e494                	sd	a3,8(s1)
    992a:	854a                	mv	a0,s2
    992c:	e398                	sd	a4,0(a5)
    992e:	1ec000ef          	jal	9b1a <__malloc_unlock>
    9932:	01040513          	addi	a0,s0,16
    9936:	bb1d                	j	966c <_malloc_r+0x1bc>
    9938:	0034d593          	srli	a1,s1,0x3
    993c:	0015879b          	addiw	a5,a1,1
    9940:	0017979b          	slliw	a5,a5,0x1
    9944:	078e                	slli	a5,a5,0x3
    9946:	2581                	sext.w	a1,a1
    9948:	be51                	j	94dc <_malloc_r+0x2c>
    994a:	0067d713          	srli	a4,a5,0x6
    994e:	0397061b          	addiw	a2,a4,57
    9952:	0016161b          	slliw	a2,a2,0x1
    9956:	060e                	slli	a2,a2,0x3
    9958:	0387069b          	addiw	a3,a4,56
    995c:	b739                	j	986a <_malloc_r+0x3ba>
    995e:	05c7859b          	addiw	a1,a5,92
    9962:	0015961b          	slliw	a2,a1,0x1
    9966:	05b7881b          	addiw	a6,a5,91
    996a:	060e                	slli	a2,a2,0x3
    996c:	bec5                	j	955c <_malloc_r+0xac>
    996e:	01033783          	ld	a5,16(t1)
    9972:	35fd                	addiw	a1,a1,-1
    9974:	18679a63          	bne	a5,t1,9b08 <_malloc_r+0x658>
    9978:	0035f793          	andi	a5,a1,3
    997c:	1341                	addi	t1,t1,-16
    997e:	fbe5                	bnez	a5,996e <_malloc_r+0x4be>
    9980:	0089b703          	ld	a4,8(s3)
    9984:	fff64793          	not	a5,a2
    9988:	8ff9                	and	a5,a5,a4
    998a:	00f9b423          	sd	a5,8(s3)
    998e:	0606                	slli	a2,a2,0x1
    9990:	cec7ece3          	bltu	a5,a2,9688 <_malloc_r+0x1d8>
    9994:	ce060ae3          	beqz	a2,9688 <_malloc_r+0x1d8>
    9998:	00f67733          	and	a4,a2,a5
    999c:	e711                	bnez	a4,99a8 <_malloc_r+0x4f8>
    999e:	0606                	slli	a2,a2,0x1
    99a0:	00f67733          	and	a4,a2,a5
    99a4:	2e11                	addiw	t3,t3,4
    99a6:	df65                	beqz	a4,999e <_malloc_r+0x4ee>
    99a8:	85f2                	mv	a1,t3
    99aa:	b98d                	j	961c <_malloc_r+0x16c>
    99ac:	01040593          	addi	a1,s0,16
    99b0:	854a                	mv	a0,s2
    99b2:	456000ef          	jal	9e08 <_free_r>
    99b6:	0003a717          	auipc	a4,0x3a
    99ba:	e7272703          	lw	a4,-398(a4) # 43828 <__malloc_current_mallinfo>
    99be:	0109bb03          	ld	s6,16(s3)
    99c2:	bbe1                	j	979a <_malloc_r+0x2ea>
    99c4:	020a0a13          	addi	s4,s4,32
    99c8:	b339                	j	96d6 <_malloc_r+0x226>
    99ca:	4026d69b          	sraiw	a3,a3,0x2
    99ce:	4785                	li	a5,1
    99d0:	00d797b3          	sll	a5,a5,a3
    99d4:	8d5d                	or	a0,a0,a5
    99d6:	00a9b423          	sd	a0,8(s3)
    99da:	b575                	j	9886 <_malloc_r+0x3d6>
    99dc:	014b0bb3          	add	s7,s6,s4
    99e0:	41700bb3          	neg	s7,s7
    99e4:	1bd2                	slli	s7,s7,0x34
    99e6:	034bdb93          	srli	s7,s7,0x34
    99ea:	85de                	mv	a1,s7
    99ec:	854a                	mv	a0,s2
    99ee:	138000ef          	jal	9b26 <_sbrk_r>
    99f2:	57fd                	li	a5,-1
    99f4:	4681                	li	a3,0
    99f6:	d4f51ce3          	bne	a0,a5,974e <_malloc_r+0x29e>
    99fa:	b385                	j	975a <_malloc_r+0x2aa>
    99fc:	6ca2                	ld	s9,8(sp)
    99fe:	4785                	li	a5,1
    9a00:	00fb3423          	sd	a5,8(s6)
    9a04:	854a                	mv	a0,s2
    9a06:	114000ef          	jal	9b1a <__malloc_unlock>
    9a0a:	7a42                	ld	s4,48(sp)
    9a0c:	7aa2                	ld	s5,40(sp)
    9a0e:	7b02                	ld	s6,32(sp)
    9a10:	6be2                	ld	s7,24(sp)
    9a12:	6c42                	ld	s8,16(sp)
    9a14:	b999                	j	966a <_malloc_r+0x1ba>
    9a16:	05400693          	li	a3,84
    9a1a:	06e6eb63          	bltu	a3,a4,9a90 <_malloc_r+0x5e0>
    9a1e:	00c7d713          	srli	a4,a5,0xc
    9a22:	06f7061b          	addiw	a2,a4,111
    9a26:	0016161b          	slliw	a2,a2,0x1
    9a2a:	060e                	slli	a2,a2,0x3
    9a2c:	06e7069b          	addiw	a3,a4,110
    9a30:	bd2d                	j	986a <_malloc_r+0x3ba>
    9a32:	15400713          	li	a4,340
    9a36:	06f76b63          	bltu	a4,a5,9aac <_malloc_r+0x5fc>
    9a3a:	00f4d793          	srli	a5,s1,0xf
    9a3e:	0787859b          	addiw	a1,a5,120
    9a42:	0015961b          	slliw	a2,a1,0x1
    9a46:	0777881b          	addiw	a6,a5,119
    9a4a:	060e                	slli	a2,a2,0x3
    9a4c:	be01                	j	955c <_malloc_r+0xac>
    9a4e:	0003a697          	auipc	a3,0x3a
    9a52:	dda6a683          	lw	a3,-550(a3) # 43828 <__malloc_current_mallinfo>
    9a56:	0003ac97          	auipc	s9,0x3a
    9a5a:	dd2c8c93          	addi	s9,s9,-558 # 43828 <__malloc_current_mallinfo>
    9a5e:	014686bb          	addw	a3,a3,s4
    9a62:	00dca023          	sw	a3,0(s9)
    9a66:	b155                	j	970a <_malloc_r+0x25a>
    9a68:	0109b403          	ld	s0,16(s3)
    9a6c:	641c                	ld	a5,8(s0)
    9a6e:	b38d                	j	97d0 <_malloc_r+0x320>
    9a70:	03451793          	slli	a5,a0,0x34
    9a74:	c8079be3          	bnez	a5,970a <_malloc_r+0x25a>
    9a78:	0109bb03          	ld	s6,16(s3)
    9a7c:	014a87b3          	add	a5,s5,s4
    9a80:	0017e793          	ori	a5,a5,1
    9a84:	00fb3423          	sd	a5,8(s6)
    9a88:	bb19                	j	979e <_malloc_r+0x2ee>
    9a8a:	016c3023          	sd	s6,0(s8)
    9a8e:	b941                	j	971e <_malloc_r+0x26e>
    9a90:	15400693          	li	a3,340
    9a94:	04e6e063          	bltu	a3,a4,9ad4 <_malloc_r+0x624>
    9a98:	00f7d713          	srli	a4,a5,0xf
    9a9c:	0787061b          	addiw	a2,a4,120
    9aa0:	0016161b          	slliw	a2,a2,0x1
    9aa4:	060e                	slli	a2,a2,0x3
    9aa6:	0777069b          	addiw	a3,a4,119
    9aaa:	b3c1                	j	986a <_malloc_r+0x3ba>
    9aac:	55400713          	li	a4,1364
    9ab0:	04f76063          	bltu	a4,a5,9af0 <_malloc_r+0x640>
    9ab4:	0124d793          	srli	a5,s1,0x12
    9ab8:	07d7859b          	addiw	a1,a5,125
    9abc:	0015961b          	slliw	a2,a1,0x1
    9ac0:	07c7881b          	addiw	a6,a5,124
    9ac4:	060e                	slli	a2,a2,0x3
    9ac6:	bc59                	j	955c <_malloc_r+0xac>
    9ac8:	1c41                	addi	s8,s8,-16
    9aca:	9a62                	add	s4,s4,s8
    9acc:	416a0a33          	sub	s4,s4,s6
    9ad0:	4681                	li	a3,0
    9ad2:	b161                	j	975a <_malloc_r+0x2aa>
    9ad4:	55400693          	li	a3,1364
    9ad8:	02e6e363          	bltu	a3,a4,9afe <_malloc_r+0x64e>
    9adc:	0127d713          	srli	a4,a5,0x12
    9ae0:	07d7061b          	addiw	a2,a4,125
    9ae4:	0016161b          	slliw	a2,a2,0x1
    9ae8:	060e                	slli	a2,a2,0x3
    9aea:	07c7069b          	addiw	a3,a4,124
    9aee:	bbb5                	j	986a <_malloc_r+0x3ba>
    9af0:	7f000613          	li	a2,2032
    9af4:	07f00593          	li	a1,127
    9af8:	07e00813          	li	a6,126
    9afc:	b485                	j	955c <_malloc_r+0xac>
    9afe:	7f000613          	li	a2,2032
    9b02:	07e00693          	li	a3,126
    9b06:	b395                	j	986a <_malloc_r+0x3ba>
    9b08:	0089b783          	ld	a5,8(s3)
    9b0c:	b549                	j	998e <_malloc_r+0x4de>

0000000000009b0e <__malloc_lock>:
    9b0e:	0003a517          	auipc	a0,0x3a
    9b12:	d7a50513          	addi	a0,a0,-646 # 43888 <__lock___malloc_recursive_mutex>
    9b16:	5460006f          	j	a05c <__retarget_lock_acquire_recursive>

0000000000009b1a <__malloc_unlock>:
    9b1a:	0003a517          	auipc	a0,0x3a
    9b1e:	d6e50513          	addi	a0,a0,-658 # 43888 <__lock___malloc_recursive_mutex>
    9b22:	5460006f          	j	a068 <__retarget_lock_release_recursive>

0000000000009b26 <_sbrk_r>:
    9b26:	1141                	addi	sp,sp,-16
    9b28:	e022                	sd	s0,0(sp)
    9b2a:	842a                	mv	s0,a0
    9b2c:	852e                	mv	a0,a1
    9b2e:	0003a797          	auipc	a5,0x3a
    9b32:	d607af23          	sw	zero,-642(a5) # 438ac <errno>
    9b36:	e406                	sd	ra,8(sp)
    9b38:	706000ef          	jal	a23e <_sbrk>
    9b3c:	57fd                	li	a5,-1
    9b3e:	00f50663          	beq	a0,a5,9b4a <_sbrk_r+0x24>
    9b42:	60a2                	ld	ra,8(sp)
    9b44:	6402                	ld	s0,0(sp)
    9b46:	0141                	addi	sp,sp,16
    9b48:	8082                	ret
    9b4a:	0003a797          	auipc	a5,0x3a
    9b4e:	d627a783          	lw	a5,-670(a5) # 438ac <errno>
    9b52:	dbe5                	beqz	a5,9b42 <_sbrk_r+0x1c>
    9b54:	60a2                	ld	ra,8(sp)
    9b56:	c01c                	sw	a5,0(s0)
    9b58:	6402                	ld	s0,0(sp)
    9b5a:	0141                	addi	sp,sp,16
    9b5c:	8082                	ret
	...

0000000000009b60 <strcmp>:
    9b60:	00b56733          	or	a4,a0,a1
    9b64:	53fd                	li	t2,-1
    9b66:	8b1d                	andi	a4,a4,7
    9b68:	eb4d                	bnez	a4,9c1a <strcmp+0xba>
    9b6a:	00001797          	auipc	a5,0x1
    9b6e:	c1e7b783          	ld	a5,-994(a5) # a788 <mask>
    9b72:	6110                	ld	a2,0(a0)
    9b74:	6194                	ld	a3,0(a1)
    9b76:	00f672b3          	and	t0,a2,a5
    9b7a:	00f66333          	or	t1,a2,a5
    9b7e:	92be                	add	t0,t0,a5
    9b80:	0062e2b3          	or	t0,t0,t1
    9b84:	0a729963          	bne	t0,t2,9c36 <strcmp+0xd6>
    9b88:	02d61e63          	bne	a2,a3,9bc4 <strcmp+0x64>
    9b8c:	6510                	ld	a2,8(a0)
    9b8e:	6594                	ld	a3,8(a1)
    9b90:	00f672b3          	and	t0,a2,a5
    9b94:	00f66333          	or	t1,a2,a5
    9b98:	92be                	add	t0,t0,a5
    9b9a:	0062e2b3          	or	t0,t0,t1
    9b9e:	08729a63          	bne	t0,t2,9c32 <strcmp+0xd2>
    9ba2:	02d61163          	bne	a2,a3,9bc4 <strcmp+0x64>
    9ba6:	6910                	ld	a2,16(a0)
    9ba8:	6994                	ld	a3,16(a1)
    9baa:	00f672b3          	and	t0,a2,a5
    9bae:	00f66333          	or	t1,a2,a5
    9bb2:	92be                	add	t0,t0,a5
    9bb4:	0062e2b3          	or	t0,t0,t1
    9bb8:	08729363          	bne	t0,t2,9c3e <strcmp+0xde>
    9bbc:	0561                	addi	a0,a0,24
    9bbe:	05e1                	addi	a1,a1,24
    9bc0:	fad609e3          	beq	a2,a3,9b72 <strcmp+0x12>
    9bc4:	03061713          	slli	a4,a2,0x30
    9bc8:	03069793          	slli	a5,a3,0x30
    9bcc:	02f71863          	bne	a4,a5,9bfc <strcmp+0x9c>
    9bd0:	02061713          	slli	a4,a2,0x20
    9bd4:	02069793          	slli	a5,a3,0x20
    9bd8:	02f71263          	bne	a4,a5,9bfc <strcmp+0x9c>
    9bdc:	01061713          	slli	a4,a2,0x10
    9be0:	01069793          	slli	a5,a3,0x10
    9be4:	00f71c63          	bne	a4,a5,9bfc <strcmp+0x9c>
    9be8:	03065713          	srli	a4,a2,0x30
    9bec:	0306d793          	srli	a5,a3,0x30
    9bf0:	40f70533          	sub	a0,a4,a5
    9bf4:	0ff57593          	zext.b	a1,a0
    9bf8:	e991                	bnez	a1,9c0c <strcmp+0xac>
    9bfa:	8082                	ret
    9bfc:	9341                	srli	a4,a4,0x30
    9bfe:	93c1                	srli	a5,a5,0x30
    9c00:	40f70533          	sub	a0,a4,a5
    9c04:	0ff57593          	zext.b	a1,a0
    9c08:	e191                	bnez	a1,9c0c <strcmp+0xac>
    9c0a:	8082                	ret
    9c0c:	0ff77713          	zext.b	a4,a4
    9c10:	0ff7f793          	zext.b	a5,a5
    9c14:	40f70533          	sub	a0,a4,a5
    9c18:	8082                	ret
    9c1a:	00054603          	lbu	a2,0(a0)
    9c1e:	0005c683          	lbu	a3,0(a1)
    9c22:	0505                	addi	a0,a0,1
    9c24:	0585                	addi	a1,a1,1
    9c26:	00d61363          	bne	a2,a3,9c2c <strcmp+0xcc>
    9c2a:	fa65                	bnez	a2,9c1a <strcmp+0xba>
    9c2c:	40d60533          	sub	a0,a2,a3
    9c30:	8082                	ret
    9c32:	0521                	addi	a0,a0,8
    9c34:	05a1                	addi	a1,a1,8
    9c36:	fed612e3          	bne	a2,a3,9c1a <strcmp+0xba>
    9c3a:	4501                	li	a0,0
    9c3c:	8082                	ret
    9c3e:	0541                	addi	a0,a0,16
    9c40:	05c1                	addi	a1,a1,16
    9c42:	fcd61ce3          	bne	a2,a3,9c1a <strcmp+0xba>
    9c46:	4501                	li	a0,0
    9c48:	8082                	ret

0000000000009c4a <strdup>:
    9c4a:	85aa                	mv	a1,a0
    9c4c:	00037517          	auipc	a0,0x37
    9c50:	33c53503          	ld	a0,828(a0) # 40f88 <_impure_ptr>
    9c54:	a009                	j	9c56 <_strdup_r>

0000000000009c56 <_strdup_r>:
    9c56:	1101                	addi	sp,sp,-32
    9c58:	e822                	sd	s0,16(sp)
    9c5a:	842a                	mv	s0,a0
    9c5c:	852e                	mv	a0,a1
    9c5e:	ec06                	sd	ra,24(sp)
    9c60:	e426                	sd	s1,8(sp)
    9c62:	e04a                	sd	s2,0(sp)
    9c64:	84ae                	mv	s1,a1
    9c66:	02a000ef          	jal	9c90 <strlen>
    9c6a:	00150913          	addi	s2,a0,1
    9c6e:	85ca                	mv	a1,s2
    9c70:	8522                	mv	a0,s0
    9c72:	83fff0ef          	jal	94b0 <_malloc_r>
    9c76:	842a                	mv	s0,a0
    9c78:	c509                	beqz	a0,9c82 <_strdup_r+0x2c>
    9c7a:	864a                	mv	a2,s2
    9c7c:	85a6                	mv	a1,s1
    9c7e:	3ee000ef          	jal	a06c <memcpy>
    9c82:	60e2                	ld	ra,24(sp)
    9c84:	8522                	mv	a0,s0
    9c86:	6442                	ld	s0,16(sp)
    9c88:	64a2                	ld	s1,8(sp)
    9c8a:	6902                	ld	s2,0(sp)
    9c8c:	6105                	addi	sp,sp,32
    9c8e:	8082                	ret

0000000000009c90 <strlen>:
    9c90:	00757793          	andi	a5,a0,7
    9c94:	872a                	mv	a4,a0
    9c96:	efb1                	bnez	a5,9cf2 <strlen+0x62>
    9c98:	7f7f87b7          	lui	a5,0x7f7f8
    9c9c:	f7f78793          	addi	a5,a5,-129 # 7f7f7f7f <__kernel_stack+0x7f709f7f>
    9ca0:	02079693          	slli	a3,a5,0x20
    9ca4:	96be                	add	a3,a3,a5
    9ca6:	55fd                	li	a1,-1
    9ca8:	6310                	ld	a2,0(a4)
    9caa:	0721                	addi	a4,a4,8
    9cac:	00d677b3          	and	a5,a2,a3
    9cb0:	97b6                	add	a5,a5,a3
    9cb2:	8fd1                	or	a5,a5,a2
    9cb4:	8fd5                	or	a5,a5,a3
    9cb6:	feb789e3          	beq	a5,a1,9ca8 <strlen+0x18>
    9cba:	ff874683          	lbu	a3,-8(a4)
    9cbe:	40a707b3          	sub	a5,a4,a0
    9cc2:	c6a9                	beqz	a3,9d0c <strlen+0x7c>
    9cc4:	ff974683          	lbu	a3,-7(a4)
    9cc8:	ce9d                	beqz	a3,9d06 <strlen+0x76>
    9cca:	ffa74683          	lbu	a3,-6(a4)
    9cce:	c6a9                	beqz	a3,9d18 <strlen+0x88>
    9cd0:	ffb74683          	lbu	a3,-5(a4)
    9cd4:	ce9d                	beqz	a3,9d12 <strlen+0x82>
    9cd6:	ffc74683          	lbu	a3,-4(a4)
    9cda:	c2b1                	beqz	a3,9d1e <strlen+0x8e>
    9cdc:	ffd74683          	lbu	a3,-3(a4)
    9ce0:	c2b1                	beqz	a3,9d24 <strlen+0x94>
    9ce2:	ffe74503          	lbu	a0,-2(a4)
    9ce6:	00a03533          	snez	a0,a0
    9cea:	953e                	add	a0,a0,a5
    9cec:	1579                	addi	a0,a0,-2
    9cee:	8082                	ret
    9cf0:	d6c5                	beqz	a3,9c98 <strlen+0x8>
    9cf2:	00074783          	lbu	a5,0(a4)
    9cf6:	0705                	addi	a4,a4,1
    9cf8:	00777693          	andi	a3,a4,7
    9cfc:	fbf5                	bnez	a5,9cf0 <strlen+0x60>
    9cfe:	8f09                	sub	a4,a4,a0
    9d00:	fff70513          	addi	a0,a4,-1
    9d04:	8082                	ret
    9d06:	ff978513          	addi	a0,a5,-7
    9d0a:	8082                	ret
    9d0c:	ff878513          	addi	a0,a5,-8
    9d10:	8082                	ret
    9d12:	ffb78513          	addi	a0,a5,-5
    9d16:	8082                	ret
    9d18:	ffa78513          	addi	a0,a5,-6
    9d1c:	8082                	ret
    9d1e:	ffc78513          	addi	a0,a5,-4
    9d22:	8082                	ret
    9d24:	ffd78513          	addi	a0,a5,-3
    9d28:	8082                	ret

0000000000009d2a <_malloc_trim_r>:
    9d2a:	7179                	addi	sp,sp,-48
    9d2c:	f022                	sd	s0,32(sp)
    9d2e:	ec26                	sd	s1,24(sp)
    9d30:	e84a                	sd	s2,16(sp)
    9d32:	e44e                	sd	s3,8(sp)
    9d34:	e052                	sd	s4,0(sp)
    9d36:	89ae                	mv	s3,a1
    9d38:	f406                	sd	ra,40(sp)
    9d3a:	892a                	mv	s2,a0
    9d3c:	00036a17          	auipc	s4,0x36
    9d40:	2cca0a13          	addi	s4,s4,716 # 40008 <__malloc_av_>
    9d44:	dcbff0ef          	jal	9b0e <__malloc_lock>
    9d48:	010a3783          	ld	a5,16(s4)
    9d4c:	6405                	lui	s0,0x1
    9d4e:	fdf40413          	addi	s0,s0,-33 # fdf <_ftoa+0x15f>
    9d52:	6784                	ld	s1,8(a5)
    9d54:	6785                	lui	a5,0x1
    9d56:	98f1                	andi	s1,s1,-4
    9d58:	9426                	add	s0,s0,s1
    9d5a:	41340433          	sub	s0,s0,s3
    9d5e:	8031                	srli	s0,s0,0xc
    9d60:	147d                	addi	s0,s0,-1
    9d62:	0432                	slli	s0,s0,0xc
    9d64:	00f44b63          	blt	s0,a5,9d7a <_malloc_trim_r+0x50>
    9d68:	4581                	li	a1,0
    9d6a:	854a                	mv	a0,s2
    9d6c:	dbbff0ef          	jal	9b26 <_sbrk_r>
    9d70:	010a3783          	ld	a5,16(s4)
    9d74:	97a6                	add	a5,a5,s1
    9d76:	00f50e63          	beq	a0,a5,9d92 <_malloc_trim_r+0x68>
    9d7a:	854a                	mv	a0,s2
    9d7c:	d9fff0ef          	jal	9b1a <__malloc_unlock>
    9d80:	70a2                	ld	ra,40(sp)
    9d82:	7402                	ld	s0,32(sp)
    9d84:	64e2                	ld	s1,24(sp)
    9d86:	6942                	ld	s2,16(sp)
    9d88:	69a2                	ld	s3,8(sp)
    9d8a:	6a02                	ld	s4,0(sp)
    9d8c:	4501                	li	a0,0
    9d8e:	6145                	addi	sp,sp,48
    9d90:	8082                	ret
    9d92:	408005b3          	neg	a1,s0
    9d96:	854a                	mv	a0,s2
    9d98:	d8fff0ef          	jal	9b26 <_sbrk_r>
    9d9c:	57fd                	li	a5,-1
    9d9e:	02f50d63          	beq	a0,a5,9dd8 <_malloc_trim_r+0xae>
    9da2:	010a3703          	ld	a4,16(s4)
    9da6:	0003a797          	auipc	a5,0x3a
    9daa:	a827a783          	lw	a5,-1406(a5) # 43828 <__malloc_current_mallinfo>
    9dae:	8c81                	sub	s1,s1,s0
    9db0:	0014e493          	ori	s1,s1,1
    9db4:	e704                	sd	s1,8(a4)
    9db6:	854a                	mv	a0,s2
    9db8:	9f81                	subw	a5,a5,s0
    9dba:	0003a717          	auipc	a4,0x3a
    9dbe:	a6f72723          	sw	a5,-1426(a4) # 43828 <__malloc_current_mallinfo>
    9dc2:	d59ff0ef          	jal	9b1a <__malloc_unlock>
    9dc6:	70a2                	ld	ra,40(sp)
    9dc8:	7402                	ld	s0,32(sp)
    9dca:	64e2                	ld	s1,24(sp)
    9dcc:	6942                	ld	s2,16(sp)
    9dce:	69a2                	ld	s3,8(sp)
    9dd0:	6a02                	ld	s4,0(sp)
    9dd2:	4505                	li	a0,1
    9dd4:	6145                	addi	sp,sp,48
    9dd6:	8082                	ret
    9dd8:	4581                	li	a1,0
    9dda:	854a                	mv	a0,s2
    9ddc:	d4bff0ef          	jal	9b26 <_sbrk_r>
    9de0:	010a3703          	ld	a4,16(s4)
    9de4:	46fd                	li	a3,31
    9de6:	40e507b3          	sub	a5,a0,a4
    9dea:	f8f6d8e3          	bge	a3,a5,9d7a <_malloc_trim_r+0x50>
    9dee:	00037697          	auipc	a3,0x37
    9df2:	18a6b683          	ld	a3,394(a3) # 40f78 <__malloc_sbrk_base>
    9df6:	0017e793          	ori	a5,a5,1
    9dfa:	e71c                	sd	a5,8(a4)
    9dfc:	8d15                	sub	a0,a0,a3
    9dfe:	0003a797          	auipc	a5,0x3a
    9e02:	a2a7a523          	sw	a0,-1494(a5) # 43828 <__malloc_current_mallinfo>
    9e06:	bf95                	j	9d7a <_malloc_trim_r+0x50>

0000000000009e08 <_free_r>:
    9e08:	c1fd                	beqz	a1,9eee <_free_r+0xe6>
    9e0a:	1101                	addi	sp,sp,-32
    9e0c:	e822                	sd	s0,16(sp)
    9e0e:	e426                	sd	s1,8(sp)
    9e10:	842e                	mv	s0,a1
    9e12:	84aa                	mv	s1,a0
    9e14:	ec06                	sd	ra,24(sp)
    9e16:	cf9ff0ef          	jal	9b0e <__malloc_lock>
    9e1a:	ff843583          	ld	a1,-8(s0)
    9e1e:	ff040713          	addi	a4,s0,-16
    9e22:	00036817          	auipc	a6,0x36
    9e26:	1e680813          	addi	a6,a6,486 # 40008 <__malloc_av_>
    9e2a:	ffe5f793          	andi	a5,a1,-2
    9e2e:	00f70633          	add	a2,a4,a5
    9e32:	6614                	ld	a3,8(a2)
    9e34:	01083503          	ld	a0,16(a6)
    9e38:	0015f893          	andi	a7,a1,1
    9e3c:	9af1                	andi	a3,a3,-4
    9e3e:	12c50563          	beq	a0,a2,9f68 <_free_r+0x160>
    9e42:	e614                	sd	a3,8(a2)
    9e44:	00d60533          	add	a0,a2,a3
    9e48:	6508                	ld	a0,8(a0)
    9e4a:	8905                	andi	a0,a0,1
    9e4c:	06089e63          	bnez	a7,9ec8 <_free_r+0xc0>
    9e50:	ff043303          	ld	t1,-16(s0)
    9e54:	00036897          	auipc	a7,0x36
    9e58:	1c488893          	addi	a7,a7,452 # 40018 <__malloc_av_+0x10>
    9e5c:	40670733          	sub	a4,a4,t1
    9e60:	6b0c                	ld	a1,16(a4)
    9e62:	979a                	add	a5,a5,t1
    9e64:	0f158663          	beq	a1,a7,9f50 <_free_r+0x148>
    9e68:	01873303          	ld	t1,24(a4)
    9e6c:	0065bc23          	sd	t1,24(a1)
    9e70:	00b33823          	sd	a1,16(t1)
    9e74:	12050863          	beqz	a0,9fa4 <_free_r+0x19c>
    9e78:	0017e693          	ori	a3,a5,1
    9e7c:	e714                	sd	a3,8(a4)
    9e7e:	e21c                	sd	a5,0(a2)
    9e80:	1ff00693          	li	a3,511
    9e84:	06f6ef63          	bltu	a3,a5,9f02 <_free_r+0xfa>
    9e88:	838d                	srli	a5,a5,0x3
    9e8a:	2781                	sext.w	a5,a5
    9e8c:	0017869b          	addiw	a3,a5,1
    9e90:	0016969b          	slliw	a3,a3,0x1
    9e94:	068e                	slli	a3,a3,0x3
    9e96:	00883503          	ld	a0,8(a6)
    9e9a:	96c2                	add	a3,a3,a6
    9e9c:	628c                	ld	a1,0(a3)
    9e9e:	4605                	li	a2,1
    9ea0:	4027d79b          	sraiw	a5,a5,0x2
    9ea4:	00f617b3          	sll	a5,a2,a5
    9ea8:	8fc9                	or	a5,a5,a0
    9eaa:	ff068613          	addi	a2,a3,-16
    9eae:	eb0c                	sd	a1,16(a4)
    9eb0:	ef10                	sd	a2,24(a4)
    9eb2:	00f83423          	sd	a5,8(a6)
    9eb6:	e298                	sd	a4,0(a3)
    9eb8:	ed98                	sd	a4,24(a1)
    9eba:	6442                	ld	s0,16(sp)
    9ebc:	60e2                	ld	ra,24(sp)
    9ebe:	8526                	mv	a0,s1
    9ec0:	64a2                	ld	s1,8(sp)
    9ec2:	6105                	addi	sp,sp,32
    9ec4:	c57ff06f          	j	9b1a <__malloc_unlock>
    9ec8:	e505                	bnez	a0,9ef0 <_free_r+0xe8>
    9eca:	97b6                	add	a5,a5,a3
    9ecc:	00036897          	auipc	a7,0x36
    9ed0:	14c88893          	addi	a7,a7,332 # 40018 <__malloc_av_+0x10>
    9ed4:	6a14                	ld	a3,16(a2)
    9ed6:	0017e513          	ori	a0,a5,1
    9eda:	00f705b3          	add	a1,a4,a5
    9ede:	11168363          	beq	a3,a7,9fe4 <_free_r+0x1dc>
    9ee2:	6e10                	ld	a2,24(a2)
    9ee4:	ee90                	sd	a2,24(a3)
    9ee6:	ea14                	sd	a3,16(a2)
    9ee8:	e708                	sd	a0,8(a4)
    9eea:	e19c                	sd	a5,0(a1)
    9eec:	bf51                	j	9e80 <_free_r+0x78>
    9eee:	8082                	ret
    9ef0:	0015e593          	ori	a1,a1,1
    9ef4:	feb43c23          	sd	a1,-8(s0)
    9ef8:	e21c                	sd	a5,0(a2)
    9efa:	1ff00693          	li	a3,511
    9efe:	f8f6f5e3          	bgeu	a3,a5,9e88 <_free_r+0x80>
    9f02:	0097d693          	srli	a3,a5,0x9
    9f06:	4611                	li	a2,4
    9f08:	0ad66063          	bltu	a2,a3,9fa8 <_free_r+0x1a0>
    9f0c:	0067d693          	srli	a3,a5,0x6
    9f10:	0396859b          	addiw	a1,a3,57
    9f14:	0015959b          	slliw	a1,a1,0x1
    9f18:	058e                	slli	a1,a1,0x3
    9f1a:	0386861b          	addiw	a2,a3,56
    9f1e:	95c2                	add	a1,a1,a6
    9f20:	6194                	ld	a3,0(a1)
    9f22:	15c1                	addi	a1,a1,-16
    9f24:	00d59663          	bne	a1,a3,9f30 <_free_r+0x128>
    9f28:	a8c9                	j	9ffa <_free_r+0x1f2>
    9f2a:	6a94                	ld	a3,16(a3)
    9f2c:	00d58663          	beq	a1,a3,9f38 <_free_r+0x130>
    9f30:	6690                	ld	a2,8(a3)
    9f32:	9a71                	andi	a2,a2,-4
    9f34:	fec7ebe3          	bltu	a5,a2,9f2a <_free_r+0x122>
    9f38:	6e8c                	ld	a1,24(a3)
    9f3a:	ef0c                	sd	a1,24(a4)
    9f3c:	eb14                	sd	a3,16(a4)
    9f3e:	6442                	ld	s0,16(sp)
    9f40:	60e2                	ld	ra,24(sp)
    9f42:	e998                	sd	a4,16(a1)
    9f44:	8526                	mv	a0,s1
    9f46:	64a2                	ld	s1,8(sp)
    9f48:	ee98                	sd	a4,24(a3)
    9f4a:	6105                	addi	sp,sp,32
    9f4c:	bcfff06f          	j	9b1a <__malloc_unlock>
    9f50:	ed2d                	bnez	a0,9fca <_free_r+0x1c2>
    9f52:	6e0c                	ld	a1,24(a2)
    9f54:	6a10                	ld	a2,16(a2)
    9f56:	96be                	add	a3,a3,a5
    9f58:	0016e793          	ori	a5,a3,1
    9f5c:	ee0c                	sd	a1,24(a2)
    9f5e:	e990                	sd	a2,16(a1)
    9f60:	e71c                	sd	a5,8(a4)
    9f62:	9736                	add	a4,a4,a3
    9f64:	e314                	sd	a3,0(a4)
    9f66:	bf91                	j	9eba <_free_r+0xb2>
    9f68:	96be                	add	a3,a3,a5
    9f6a:	00089a63          	bnez	a7,9f7e <_free_r+0x176>
    9f6e:	ff043583          	ld	a1,-16(s0)
    9f72:	8f0d                	sub	a4,a4,a1
    9f74:	6f1c                	ld	a5,24(a4)
    9f76:	6b10                	ld	a2,16(a4)
    9f78:	96ae                	add	a3,a3,a1
    9f7a:	ee1c                	sd	a5,24(a2)
    9f7c:	eb90                	sd	a2,16(a5)
    9f7e:	0016e613          	ori	a2,a3,1
    9f82:	00037797          	auipc	a5,0x37
    9f86:	ffe7b783          	ld	a5,-2(a5) # 40f80 <__malloc_trim_threshold>
    9f8a:	e710                	sd	a2,8(a4)
    9f8c:	00e83823          	sd	a4,16(a6)
    9f90:	f2f6e5e3          	bltu	a3,a5,9eba <_free_r+0xb2>
    9f94:	0003a597          	auipc	a1,0x3a
    9f98:	8cc5b583          	ld	a1,-1844(a1) # 43860 <__malloc_top_pad>
    9f9c:	8526                	mv	a0,s1
    9f9e:	d8dff0ef          	jal	9d2a <_malloc_trim_r>
    9fa2:	bf21                	j	9eba <_free_r+0xb2>
    9fa4:	97b6                	add	a5,a5,a3
    9fa6:	b73d                	j	9ed4 <_free_r+0xcc>
    9fa8:	4651                	li	a2,20
    9faa:	02d67563          	bgeu	a2,a3,9fd4 <_free_r+0x1cc>
    9fae:	05400613          	li	a2,84
    9fb2:	04d66f63          	bltu	a2,a3,a010 <_free_r+0x208>
    9fb6:	00c7d693          	srli	a3,a5,0xc
    9fba:	06f6859b          	addiw	a1,a3,111
    9fbe:	0015959b          	slliw	a1,a1,0x1
    9fc2:	058e                	slli	a1,a1,0x3
    9fc4:	06e6861b          	addiw	a2,a3,110
    9fc8:	bf99                	j	9f1e <_free_r+0x116>
    9fca:	0017e693          	ori	a3,a5,1
    9fce:	e714                	sd	a3,8(a4)
    9fd0:	e21c                	sd	a5,0(a2)
    9fd2:	b5e5                	j	9eba <_free_r+0xb2>
    9fd4:	05c6859b          	addiw	a1,a3,92
    9fd8:	0015959b          	slliw	a1,a1,0x1
    9fdc:	058e                	slli	a1,a1,0x3
    9fde:	05b6861b          	addiw	a2,a3,91
    9fe2:	bf35                	j	9f1e <_free_r+0x116>
    9fe4:	02e83423          	sd	a4,40(a6)
    9fe8:	02e83023          	sd	a4,32(a6)
    9fec:	01173c23          	sd	a7,24(a4)
    9ff0:	01173823          	sd	a7,16(a4)
    9ff4:	e708                	sd	a0,8(a4)
    9ff6:	e19c                	sd	a5,0(a1)
    9ff8:	b5c9                	j	9eba <_free_r+0xb2>
    9ffa:	00883503          	ld	a0,8(a6)
    9ffe:	4026561b          	sraiw	a2,a2,0x2
    a002:	4785                	li	a5,1
    a004:	00c797b3          	sll	a5,a5,a2
    a008:	8fc9                	or	a5,a5,a0
    a00a:	00f83423          	sd	a5,8(a6)
    a00e:	b735                	j	9f3a <_free_r+0x132>
    a010:	15400613          	li	a2,340
    a014:	00d66c63          	bltu	a2,a3,a02c <_free_r+0x224>
    a018:	00f7d693          	srli	a3,a5,0xf
    a01c:	0786859b          	addiw	a1,a3,120
    a020:	0015959b          	slliw	a1,a1,0x1
    a024:	058e                	slli	a1,a1,0x3
    a026:	0776861b          	addiw	a2,a3,119
    a02a:	bdd5                	j	9f1e <_free_r+0x116>
    a02c:	55400613          	li	a2,1364
    a030:	00d66c63          	bltu	a2,a3,a048 <_free_r+0x240>
    a034:	0127d693          	srli	a3,a5,0x12
    a038:	07d6859b          	addiw	a1,a3,125
    a03c:	0015959b          	slliw	a1,a1,0x1
    a040:	058e                	slli	a1,a1,0x3
    a042:	07c6861b          	addiw	a2,a3,124
    a046:	bde1                	j	9f1e <_free_r+0x116>
    a048:	7f000593          	li	a1,2032
    a04c:	07e00613          	li	a2,126
    a050:	b5f9                	j	9f1e <_free_r+0x116>

000000000000a052 <__retarget_lock_init>:
    a052:	8082                	ret

000000000000a054 <__retarget_lock_init_recursive>:
    a054:	8082                	ret

000000000000a056 <__retarget_lock_close>:
    a056:	8082                	ret

000000000000a058 <__retarget_lock_close_recursive>:
    a058:	8082                	ret

000000000000a05a <__retarget_lock_acquire>:
    a05a:	8082                	ret

000000000000a05c <__retarget_lock_acquire_recursive>:
    a05c:	8082                	ret

000000000000a05e <__retarget_lock_try_acquire>:
    a05e:	4505                	li	a0,1
    a060:	8082                	ret

000000000000a062 <__retarget_lock_try_acquire_recursive>:
    a062:	4505                	li	a0,1
    a064:	8082                	ret

000000000000a066 <__retarget_lock_release>:
    a066:	8082                	ret

000000000000a068 <__retarget_lock_release_recursive>:
    a068:	8082                	ret
	...

000000000000a06c <memcpy>:
    a06c:	00863693          	sltiu	a3,a2,8
    a070:	82aa                	mv	t0,a0
    a072:	00c50333          	add	t1,a0,a2
    a076:	eeb5                	bnez	a3,a0f2 <memcpy+0x86>
    a078:	00b546b3          	xor	a3,a0,a1
    a07c:	8a9d                	andi	a3,a3,7
    a07e:	eab5                	bnez	a3,a0f2 <memcpy+0x86>
    a080:	00757693          	andi	a3,a0,7
    a084:	43a1                	li	t2,8
    a086:	e2c9                	bnez	a3,a108 <memcpy+0x9c>
    a088:	ff837393          	andi	t2,t1,-8
    a08c:	fc038313          	addi	t1,t2,-64
    a090:	04a36263          	bltu	t1,a0,a0d4 <memcpy+0x68>
    a094:	03f67613          	andi	a2,a2,63
    a098:	6198                	ld	a4,0(a1)
    a09a:	e118                	sd	a4,0(a0)
    a09c:	659c                	ld	a5,8(a1)
    a09e:	e51c                	sd	a5,8(a0)
    a0a0:	0105b803          	ld	a6,16(a1)
    a0a4:	01053823          	sd	a6,16(a0)
    a0a8:	0185b883          	ld	a7,24(a1)
    a0ac:	01153c23          	sd	a7,24(a0)
    a0b0:	7198                	ld	a4,32(a1)
    a0b2:	f118                	sd	a4,32(a0)
    a0b4:	759c                	ld	a5,40(a1)
    a0b6:	f51c                	sd	a5,40(a0)
    a0b8:	0305b803          	ld	a6,48(a1)
    a0bc:	03053823          	sd	a6,48(a0)
    a0c0:	0385b883          	ld	a7,56(a1)
    a0c4:	04058593          	addi	a1,a1,64
    a0c8:	03153c23          	sd	a7,56(a0)
    a0cc:	04050513          	addi	a0,a0,64
    a0d0:	fca374e3          	bgeu	t1,a0,a098 <memcpy+0x2c>
    a0d4:	ff837393          	andi	t2,t1,-8
    a0d8:	ff838313          	addi	t1,t2,-8
    a0dc:	00a36963          	bltu	t1,a0,a0ee <memcpy+0x82>
    a0e0:	8a0d                	andi	a2,a2,3
    a0e2:	4198                	lw	a4,0(a1)
    a0e4:	0591                	addi	a1,a1,4
    a0e6:	c118                	sw	a4,0(a0)
    a0e8:	0511                	addi	a0,a0,4
    a0ea:	fea37ce3          	bgeu	t1,a0,a0e2 <memcpy+0x76>
    a0ee:	00c50333          	add	t1,a0,a2
    a0f2:	ca09                	beqz	a2,a104 <memcpy+0x98>
    a0f4:	00058703          	lb	a4,0(a1)
    a0f8:	0585                	addi	a1,a1,1
    a0fa:	00e50023          	sb	a4,0(a0)
    a0fe:	0505                	addi	a0,a0,1
    a100:	fe656ae3          	bltu	a0,t1,a0f4 <memcpy+0x88>
    a104:	8516                	mv	a0,t0
    a106:	8082                	ret
    a108:	40d386b3          	sub	a3,t2,a3
    a10c:	83b6                	mv	t2,a3
    a10e:	00058703          	lb	a4,0(a1)
    a112:	0585                	addi	a1,a1,1
    a114:	16fd                	addi	a3,a3,-1
    a116:	00e50023          	sb	a4,0(a0)
    a11a:	0505                	addi	a0,a0,1
    a11c:	faed                	bnez	a3,a10e <memcpy+0xa2>
    a11e:	40760633          	sub	a2,a2,t2
    a122:	00263693          	sltiu	a3,a2,2
    a126:	f6f1                	bnez	a3,a0f2 <memcpy+0x86>
    a128:	b785                	j	a088 <memcpy+0x1c>

000000000000a12a <cleanup_glue>:
    a12a:	7179                	addi	sp,sp,-48
    a12c:	e84a                	sd	s2,16(sp)
    a12e:	0005b903          	ld	s2,0(a1)
    a132:	f022                	sd	s0,32(sp)
    a134:	ec26                	sd	s1,24(sp)
    a136:	f406                	sd	ra,40(sp)
    a138:	842e                	mv	s0,a1
    a13a:	84aa                	mv	s1,a0
    a13c:	02090f63          	beqz	s2,a17a <cleanup_glue+0x50>
    a140:	e44e                	sd	s3,8(sp)
    a142:	00093983          	ld	s3,0(s2)
    a146:	02098563          	beqz	s3,a170 <cleanup_glue+0x46>
    a14a:	e052                	sd	s4,0(sp)
    a14c:	0009ba03          	ld	s4,0(s3)
    a150:	000a0b63          	beqz	s4,a166 <cleanup_glue+0x3c>
    a154:	000a3583          	ld	a1,0(s4)
    a158:	c199                	beqz	a1,a15e <cleanup_glue+0x34>
    a15a:	fd1ff0ef          	jal	a12a <cleanup_glue>
    a15e:	85d2                	mv	a1,s4
    a160:	8526                	mv	a0,s1
    a162:	ca7ff0ef          	jal	9e08 <_free_r>
    a166:	85ce                	mv	a1,s3
    a168:	8526                	mv	a0,s1
    a16a:	c9fff0ef          	jal	9e08 <_free_r>
    a16e:	6a02                	ld	s4,0(sp)
    a170:	85ca                	mv	a1,s2
    a172:	8526                	mv	a0,s1
    a174:	c95ff0ef          	jal	9e08 <_free_r>
    a178:	69a2                	ld	s3,8(sp)
    a17a:	85a2                	mv	a1,s0
    a17c:	7402                	ld	s0,32(sp)
    a17e:	70a2                	ld	ra,40(sp)
    a180:	6942                	ld	s2,16(sp)
    a182:	8526                	mv	a0,s1
    a184:	64e2                	ld	s1,24(sp)
    a186:	6145                	addi	sp,sp,48
    a188:	c81ff06f          	j	9e08 <_free_r>

000000000000a18c <_reclaim_reent>:
    a18c:	00037797          	auipc	a5,0x37
    a190:	dfc7b783          	ld	a5,-516(a5) # 40f88 <_impure_ptr>
    a194:	0aa78463          	beq	a5,a0,a23c <_reclaim_reent+0xb0>
    a198:	7d2c                	ld	a1,120(a0)
    a19a:	7179                	addi	sp,sp,-48
    a19c:	ec26                	sd	s1,24(sp)
    a19e:	f406                	sd	ra,40(sp)
    a1a0:	f022                	sd	s0,32(sp)
    a1a2:	e84a                	sd	s2,16(sp)
    a1a4:	84aa                	mv	s1,a0
    a1a6:	c59d                	beqz	a1,a1d4 <_reclaim_reent+0x48>
    a1a8:	e44e                	sd	s3,8(sp)
    a1aa:	4901                	li	s2,0
    a1ac:	20000993          	li	s3,512
    a1b0:	012587b3          	add	a5,a1,s2
    a1b4:	6380                	ld	s0,0(a5)
    a1b6:	c801                	beqz	s0,a1c6 <_reclaim_reent+0x3a>
    a1b8:	85a2                	mv	a1,s0
    a1ba:	6000                	ld	s0,0(s0)
    a1bc:	8526                	mv	a0,s1
    a1be:	c4bff0ef          	jal	9e08 <_free_r>
    a1c2:	f87d                	bnez	s0,a1b8 <_reclaim_reent+0x2c>
    a1c4:	7cac                	ld	a1,120(s1)
    a1c6:	0921                	addi	s2,s2,8
    a1c8:	ff3914e3          	bne	s2,s3,a1b0 <_reclaim_reent+0x24>
    a1cc:	8526                	mv	a0,s1
    a1ce:	c3bff0ef          	jal	9e08 <_free_r>
    a1d2:	69a2                	ld	s3,8(sp)
    a1d4:	70ac                	ld	a1,96(s1)
    a1d6:	c581                	beqz	a1,a1de <_reclaim_reent+0x52>
    a1d8:	8526                	mv	a0,s1
    a1da:	c2fff0ef          	jal	9e08 <_free_r>
    a1de:	1f84b403          	ld	s0,504(s1)
    a1e2:	cc01                	beqz	s0,a1fa <_reclaim_reent+0x6e>
    a1e4:	20048913          	addi	s2,s1,512
    a1e8:	01240963          	beq	s0,s2,a1fa <_reclaim_reent+0x6e>
    a1ec:	85a2                	mv	a1,s0
    a1ee:	6000                	ld	s0,0(s0)
    a1f0:	8526                	mv	a0,s1
    a1f2:	c17ff0ef          	jal	9e08 <_free_r>
    a1f6:	fe891be3          	bne	s2,s0,a1ec <_reclaim_reent+0x60>
    a1fa:	64cc                	ld	a1,136(s1)
    a1fc:	c581                	beqz	a1,a204 <_reclaim_reent+0x78>
    a1fe:	8526                	mv	a0,s1
    a200:	c09ff0ef          	jal	9e08 <_free_r>
    a204:	48bc                	lw	a5,80(s1)
    a206:	c78d                	beqz	a5,a230 <_reclaim_reent+0xa4>
    a208:	6cbc                	ld	a5,88(s1)
    a20a:	8526                	mv	a0,s1
    a20c:	9782                	jalr	a5
    a20e:	5204b403          	ld	s0,1312(s1)
    a212:	cc19                	beqz	s0,a230 <_reclaim_reent+0xa4>
    a214:	600c                	ld	a1,0(s0)
    a216:	c581                	beqz	a1,a21e <_reclaim_reent+0x92>
    a218:	8526                	mv	a0,s1
    a21a:	f11ff0ef          	jal	a12a <cleanup_glue>
    a21e:	85a2                	mv	a1,s0
    a220:	7402                	ld	s0,32(sp)
    a222:	70a2                	ld	ra,40(sp)
    a224:	6942                	ld	s2,16(sp)
    a226:	8526                	mv	a0,s1
    a228:	64e2                	ld	s1,24(sp)
    a22a:	6145                	addi	sp,sp,48
    a22c:	bddff06f          	j	9e08 <_free_r>
    a230:	70a2                	ld	ra,40(sp)
    a232:	7402                	ld	s0,32(sp)
    a234:	64e2                	ld	s1,24(sp)
    a236:	6942                	ld	s2,16(sp)
    a238:	6145                	addi	sp,sp,48
    a23a:	8082                	ret
    a23c:	8082                	ret

000000000000a23e <_sbrk>:
    a23e:	00039317          	auipc	t1,0x39
    a242:	67230313          	addi	t1,t1,1650 # 438b0 <heap_end.0>
    a246:	00033783          	ld	a5,0(t1)
    a24a:	1141                	addi	sp,sp,-16
    a24c:	e406                	sd	ra,8(sp)
    a24e:	882a                	mv	a6,a0
    a250:	e385                	bnez	a5,a270 <_sbrk+0x32>
    a252:	4501                	li	a0,0
    a254:	4581                	li	a1,0
    a256:	4601                	li	a2,0
    a258:	4681                	li	a3,0
    a25a:	4701                	li	a4,0
    a25c:	0d600893          	li	a7,214
    a260:	00000073          	ecall
    a264:	577d                	li	a4,-1
    a266:	87aa                	mv	a5,a0
    a268:	02e50a63          	beq	a0,a4,a29c <_sbrk+0x5e>
    a26c:	00a33023          	sd	a0,0(t1)
    a270:	00f80533          	add	a0,a6,a5
    a274:	4581                	li	a1,0
    a276:	4601                	li	a2,0
    a278:	4681                	li	a3,0
    a27a:	4701                	li	a4,0
    a27c:	4781                	li	a5,0
    a27e:	0d600893          	li	a7,214
    a282:	00000073          	ecall
    a286:	00033783          	ld	a5,0(t1)
    a28a:	983e                	add	a6,a6,a5
    a28c:	01051863          	bne	a0,a6,a29c <_sbrk+0x5e>
    a290:	60a2                	ld	ra,8(sp)
    a292:	00a33023          	sd	a0,0(t1)
    a296:	853e                	mv	a0,a5
    a298:	0141                	addi	sp,sp,16
    a29a:	8082                	ret
    a29c:	010000ef          	jal	a2ac <__errno>
    a2a0:	60a2                	ld	ra,8(sp)
    a2a2:	47b1                	li	a5,12
    a2a4:	c11c                	sw	a5,0(a0)
    a2a6:	557d                	li	a0,-1
    a2a8:	0141                	addi	sp,sp,16
    a2aa:	8082                	ret

000000000000a2ac <__errno>:
    a2ac:	00037517          	auipc	a0,0x37
    a2b0:	cdc53503          	ld	a0,-804(a0) # 40f88 <_impure_ptr>
    a2b4:	8082                	ret
