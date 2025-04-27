use std::fmt::Display;
use std::ops;
use std::simd::prelude::*;

const LANES: usize = 16;

#[derive(Debug, Copy, Clone)]
pub struct Complex {
    pub re: f64,
    pub im: f64,
}
impl ops::Add for Complex {
    type Output = Complex;

    fn add(self, rhs: Complex) -> Complex {
        Complex {
            re: self.re + rhs.re,
            im: self.im + rhs.im,
        }
    }
}

impl ops::Sub for Complex {
    type Output = Complex;

    fn sub(self, rhs: Complex) -> Complex {
        Complex {
            re: self.re - rhs.re,
            im: self.im - rhs.im,
        }
    }
}

impl ops::Mul for Complex {
    type Output = Complex;

    fn mul(self, rhs: Complex) -> Complex {
        Complex {
            re: self.re * rhs.re - self.im * rhs.im,
            im: self.re * rhs.im + self.im * rhs.re,
        }
    }
}

#[derive(Debug, Copy, Clone)]
pub struct I;

impl ops::Mul<I> for f64 {
    type Output = Complex;

    fn mul(self, _i: I) -> Complex {
        Complex { re: 0.0, im: self }
    }
}

impl ops::Mul<I> for i32 {
    type Output = Complex;

    fn mul(self, _i: I) -> Complex {
        Complex {
            re: 0.0,
            im: self as f64,
        }
    }
}

impl ops::Add<Complex> for f64 {
    type Output = Complex;

    fn add(self, rhs: Complex) -> Complex {
        Complex {
            re: self + rhs.re,
            im: rhs.im,
        }
    }
}

impl ops::Add<Complex> for i32 {
    type Output = Complex;

    fn add(self, rhs: Complex) -> Complex {
        Complex {
            re: self as f64 + rhs.re,
            im: rhs.im,
        }
    }
}

impl ops::Sub<Complex> for f64 {
    type Output = Complex;

    fn sub(self, rhs: Complex) -> Complex {
        Complex {
            re: self + rhs.re,
            im: -rhs.im,
        }
    }
}

impl ops::Sub<Complex> for i32 {
    type Output = Complex;

    fn sub(self, rhs: Complex) -> Complex {
        Complex {
            re: self as f64 - rhs.re,
            im: -rhs.im,
        }
    }
}

impl ops::Add<f64> for Complex {
    type Output = Complex;

    fn add(self, rhs: f64) -> Complex {
        Complex {
            re: self.re + rhs,
            im: self.im,
        }
    }
}

impl ops::Add<i32> for Complex {
    type Output = Complex;

    fn add(self, rhs: i32) -> Complex {
        Complex {
            re: self.re + rhs as f64,
            im: self.im,
        }
    }
}

impl ops::Sub<f64> for Complex {
    type Output = Complex;

    fn sub(self, rhs: f64) -> Complex {
        Complex {
            re: self.re - rhs as f64,
            im: self.im,
        }
    }
}

impl ops::Sub<i32> for Complex {
    type Output = Complex;

    fn sub(self, rhs: i32) -> Complex {
        Complex {
            re: self.re - rhs as f64,
            im: self.im,
        }
    }
}

pub struct ComplexSIMD<const N: usize> {
    pub re: [f64; N],
    pub im: [f64; N],
}

impl<const N: usize> ops::Mul for &ComplexSIMD<N> {
    type Output = Complex;

    fn mul(self, other: Self) -> Self::Output {
        let simd_length = (N / LANES) * LANES;

        let mut sum_re = 0.0;
        let mut sum_im = 0.0;

        if simd_length <= 0 {
            panic!("Bad input length")
        }

        let mut sum_re_simd = f64x16::splat(0.0);
        let mut sum_im_simd = f64x16::splat(0.0);

        for i in (0..simd_length).step_by(LANES) {
            let self_re = f64x16::from_slice(&self.re[i..i + LANES]);
            let self_im = f64x16::from_slice(&self.im[i..i + LANES]);
            let other_re = f64x16::from_slice(&other.re[i..i + LANES]);
            let other_im = f64x16::from_slice(&other.im[i..i + LANES]);

            let conj_re = self_re;
            let conj_im = -self_im;

            let prod_re = conj_re * other_re - conj_im * other_im;
            let prod_im = conj_re * other_im + conj_im * other_re;

            sum_re_simd += prod_re;
            sum_im_simd += prod_im;
        }

        for i in 0..LANES {
            sum_re += sum_re_simd[i];
            sum_im += sum_im_simd[i];
        }

        for i in simd_length..N {
            let conj_re = self.re[i];
            let conj_im = -self.im[i];

            sum_re += conj_re * other.re[i] - conj_im * other.im[i];
            sum_im += conj_re * other.im[i] + conj_im * other.re[i];
        }

        return Complex {
            re: sum_re,
            im: sum_im,
        };
    }
}

impl<const N: usize> Display for ComplexSIMD<N> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "[")?;
        for i in 0..N {
            if i > 0 {
                write!(f, ", ")?;
            }
            if self.im[i] >= 0.0 {
                write!(f, "{} + {}i", self.re[i], self.im[i])?;
            } else {
                write!(f, "{} - {}i", self.re[i], -self.im[i])?;
            }
        }
        write!(f, "]")
    }
}

impl<const N: usize> ComplexSIMD<N> {
    pub fn new() -> ComplexSIMD<N> {
        return ComplexSIMD::<N> {
            re: [0.0; N],
            im: [0.0; N],
        };
    }

    pub fn filled(default_num: Complex) -> ComplexSIMD<N> {
        return ComplexSIMD {
            re: [default_num.re; N],
            im: [default_num.im; N],
        };
    }

    pub fn from_array(array: [Complex; N]) -> ComplexSIMD<N> {
        let mut out_re = [0.0; N];
        let mut out_im = [0.0; N];

        for i in 0..N {
            out_re[i] = array[i].re;
            out_im[i] = array[i].im;
        }
        return ComplexSIMD {
            re: out_re,
            im: out_im,
        };
    }
}
