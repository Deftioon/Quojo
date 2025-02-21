from max.tensor import Tensor, TensorSpec, TensorShape;
from max.engine import InputSpec, InferenceSession;
import max;
from utils.index import Index;
import complex;
import math;

struct ZSpider:
    var re: Tensor[DType.float32];
    var im: Tensor[DType.float32];

    fn __init__(out self, alpha: Float32, size: Int):
        var spec = TensorSpec(DType.float32, size, size);
        self.re = Tensor[DType.float32](spec);
        self.im = Tensor[DType.float32](spec);

        # Use euler's form e^(i*theta) = cos(theta) + i*sin(theta)
        var __item = complex.ComplexFloat32(math.cos(alpha), math.sin(alpha));

        # Write into tensor
        self.re[Index(0, 0)] = 1.0;
        self.re[Index(size-1, size-1)] = __item.re;
        self.im[Index(size-1, size-1)] = __item.im;

    fn __init__(out self, alpha: Float32, size: TensorShape):
        var spec = TensorSpec(DType.float32, size);
        self.re = Tensor[DType.float32](spec);
        self.im = Tensor[DType.float32](spec);

        # Use euler's form e^(i*theta) = cos(theta) + i*sin(theta)
        var __item = complex.ComplexFloat32(math.cos(alpha), math.sin(alpha));

        # Write into tensor
        self.re[Index(0, 0)] = 1.0;
        self.re[Index(size[0]-1, size[1]-1)] = __item.re;
        self.im[Index(size[0]-1, size[1]-1)] = __item.im;

    fn __copyinit__(mut self, other: ZSpider):
        var spec = TensorSpec(DType.float32, other.re.shape());
        self.re = Tensor[DType.float32](spec);
        self.im = Tensor[DType.float32](spec);
        self.re.__copyinit__(other.re);
        self.im.__copyinit__(other.im); 
    
    fn print(read self):
        print(str(self.re));
        print(str(self.im));

    fn __add__(read self, other: ZSpider) raises -> ZSpider:
        var result = ZSpider(0.0, self.re.shape());
        result.re = self.re + other.re;
        result.im = self.im + other.im;
        return result;

    fn __sub__(read self, other: ZSpider) raises -> ZSpider:
        var result = ZSpider(0.0, self.re.shape());
        result.re = self.re - other.re;
        result.im = self.im - other.im;
        return result;
    
    fn __mul__(read self, other: ZSpider) raises -> ZSpider:
        var result = ZSpider(0.0, self.re.shape());
        result.re = self.re * other.re - self.im * other.im;
        result.im = self.re * other.im + self.im * other.re;
        return result;

    fn __div__(read self, other: ZSpider) raises -> ZSpider:
        var result = ZSpider(0.0, self.re.shape());
        var denom = other.re * other.re + other.im * other.im;
        result.re = (self.re * other.re + self.im * other.im) / denom;
        result.im = (self.im * other.re - self.re * other.im) / denom;
        return result;
