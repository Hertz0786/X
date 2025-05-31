const express = require("express");
const User = require("../models/user.model");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const signup = async (req, res) => {
  try {
    const { username, fullname, password, email } = req.body;
    if (!username || !fullname || !password || !email) {
      return res.status(400).json({
        message: "Please fill all the fields",
      });
    }
    if (password.length < 6) {
      return res.status(400).json({
        message: "Password must be at least 6 characters",
      });
    }
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if(!emailRegex.test(email)) {
      return res.status(400).json({
        message: "Please enter a valid email address",
      });
    }
    const existingUser = await User.findOne({username});
    if (existingUser) {
      return res.status(400).json({
        message: "Username already exists",
      });
    }

    const existingEmail = await User.findOne({email});
    if (existingEmail) {
      return res.status(400).json({
        message: "Email already exists",
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = new User({
      username,
      fullname,
      password: hashedPassword,
      email,
    });


    if(newUser){
      const accessToken = jwt.sign({ userId: newUser._id }, process.env.JWT_SECRET, {
        expiresIn: "72h",
      });
      await newUser.save();
      res.status(200).json({
        message: "User created successfully",
        _Id: newUser._id,
        username: newUser.username,
        fullname: newUser.fullname,
        email: newUser.email,
        profileImg: newUser.profileImg,
        coverImg: newUser.coverImg,
        bio: newUser.bio,
        link: newUser.link,
        user: newUser,
        accessToken
      });
    }else {
      res.status(400).json({
        message: "User not created",
      });
    }
  } catch (error) {
    console.log("Error in signup controller", error);
    res.status(500).json({
      message: "Internal server error",
    });
  }
};

const login = async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) {
      return res.status(400).json({
        message: "Please fill all the fields",
      });
    }
    const user = await User.findOne({ username });
    if (!user) {
      return res.status(400).json({
        message: "User not found",
      });
    }
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(400).json({
        message: "Invalid password",
      });
    }
    const accessToken = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, {
      expiresIn: "72h",
    });
    res.status(200).json({
      message: "Login successful",
       _Id: user._id,
       username: user.username,
       fullname: user.fullname,
       email: user.email,
       profileImg: user.profileImg,
       coverImg: user.coverImg,
       bio: user.bio,
       link: user.link,
      user: user,
      accessToken
    });

  } catch (error) {
    console.log("Error in login controller", error);
    res.status(500).json({
      message: "Internal server error",
    });
  }
};

const logout = (req, res) => {
  try {
    res.status(200).json({
      message: "Logout successful",
    });
  } catch (error) {
    console.log("Error in logout controller", error);
    res.status(500).json({
      message: "Internal server error",
    });

  }
};

const getMe = async (req, res) => {
  try {
    const { userId } = req.user;
    const user = await User.findById(userId).select("-password");

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(200).json(user);
  } catch (error) {
    console.log("Error in getUser controller", error);
    res.status(500).json({ message: "Internal server error" });
  }
};


module.exports = {
  signup,
  login,
  logout,
  getMe,
};