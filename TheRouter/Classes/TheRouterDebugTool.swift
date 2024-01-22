//
//  TheRouterDebugTool.swift
//  TheRouter
//
//  Created by mars.yao on 2023/11/22.
//

import Foundation
import UIKit

public class TheRouterDebugTool {
    /// 检测 是否 被追踪
    @inline(__always)
    public static func checkTracing() -> Bool {
        let mib = UnsafeMutablePointer<Int32>.allocate(capacity: 4)
        mib[0] = CTL_KERN//内核查看
        mib[1] = KERN_PROC//进程查看
        mib[2] = KERN_PROC_PID//进程ID
        mib[3] = getpid()//获取pid
        var size: Int = MemoryLayout<kinfo_proc>.size
        var info: kinfo_proc? = nil
        /* 函数的返回值若为0时，证明没有错误，其他数字为错误码。 arg1 传入一个数组，该数组中的第一个元素指定本请求定向到内核的哪个子系统。第二个及其后元素依次细化指定该系统的某个部分。 arg2 数组中的元素数目 arg3 一个结构体，指向一个供内核存放该值的缓冲区，存放进程查询结果 arg4 缓冲区的大小 arg5/arg6 为了设置某个新值，arg5参数指向一个大小为arg6参数值的缓冲区。如果不准备指定一个新值，那么arg5应为一个空指针，arg6因为0. */
        sysctl(mib, 4, &info, &size, nil, 0)
        //info.kp_proc.p_flag中存放的是标志位（二进制），在proc.h文件中有p_flag的宏定义，通过&运算可知对应标志位的值是否为0。（若结果值为0则对应标志位为0）。其中P_TRACED为正在跟踪调试过程。
        if (info.unsafelyUnwrapped.kp_proc.p_flag & P_TRACED) > 0 {
            //监听到被调试
            return true
        }
        return false
    }
}
