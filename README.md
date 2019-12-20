# FPGA_Design
FPGA自主设计实验_2019.12.20_模拟与数字电路实验_大作业

简介：这个FPGA 自主设计改编自经典游戏《是男人就下一百层》，在游戏中，通过按键控制人物左右移动，在不同的横板之间跳跃。横板是水平方向的一系列 板，每一块横板都会以恒定的速度向上移动，当一块横板移到屏幕最上方而消失时，又会有新的板从屏幕最下方随机位置出现。游戏的目标时通过控制主人公的跳跃与左右移动在不同横板之间迁移，防止人物掉落到屏幕最下方或者被某一块上移的平板顶到屏幕最上方。
      实现的主要功能包括： 
      1.键盘输入；  
      2.VGA 显示：包括人物，横板，心形，背景的显示，蓝幕技术的应用，显示优先级的处理；  
      3.游戏系统：键盘控制下的人物移动与跳跃（受重力加速度公式制约），处理人物的死亡，游戏结束条件，计算剩余生命值，控制横板位置的随机生成；
     4.七段数码管模块显示得分。
