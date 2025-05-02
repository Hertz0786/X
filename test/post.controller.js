const Post = require("../models/post.model");
const User = require("../models/user.model");
const cloudinary = require("cloudinary").v2;
const Notification = require("../models/notification.model");

const createPost = async (req, res) => {
  try {
    const { text } = req.body;
    let { image } = req.body;
    const {userId} = req.user;
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    if (!text && !image) {
      return res.status(400).json({ message: "Please provide text or image" });
    }
    if (image) {
      const uploadedResponse = await cloudinary.uploader.upload(image);
      image = uploadedResponse.secure_url;
    }
    const newPost = await Post.create({
      user: userId,
      text,
      image,
    });
    await newPost.save();
    res.status(201).json({
      message: "Post created successfully",
      post: newPost,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });
  }
};

const deletePost = async (req, res) => {
  try {
    const { id } = req.params;
    const post = await Post.findById(id);
    if (!post) {
      return res.status(404).json({ message: "Post not found" });
    }
    if (post.user.toString() !== req.user.userId.toString()) {
      return res
        .status(403)
        .json({ message: "You are not authorized to delete this post" });
    }
    if (post.image) {
      const publicId = post.image.split("/").pop().split(".")[0];
      await cloudinary.uploader.destroy(publicId);
    }
    await Post.findByIdAndDelete(id);
    res.status(200).json({ message: "Post deleted successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });
  }
};

const commentOnPost = async (req, res) => {
  try {
    const { id } = req.params; // Post ID
    const { text } = req.body;
    const { userId } = req.user;
    if (!text) {
      return res.status(400).json({ message: "Please provide text" });
    }
    const post = await Post.findById(id);
    if (!post) {
      return res.status(404).json({ message: "Post not found" });
    }

    const comment = {
      user: userId,
      text,
    };
    post.comments.push(comment);
    await post.save();
    res.status(200).json({
      message: "Comment added successfully",
      post,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });
  }
};

const likeUnLikePost = async (req, res) => {
  try {
    const { id } = req.params;
    const {userId} = req.user;
    const post = await Post.findById(id);
    if (!post) {
      return res.status(404).json({ message: "Post not found" });
    }
    if (post.likes.includes(userId.toString())) {
      post.likes = post.likes.filter((like) => like.toString() !== userId.toString());
      await post.save();
      await User.updateOne({ _id: userId }, { $pull: { likedPosts: id } });

      return res.status(200).json({
        message: "Post unliked successfully",
        post,
      });
    } else {
      post.likes.push(userId);
      const notification = new Notification({
        from: userId,
        to: post.user,
        type: "like",
      });
      await notification.save();
      await post.save();
      await User.updateOne({ _id: userId }, { $push: { likedPosts: id } });
      return res.status(200).json({
        message: "Post liked successfully",
        post,
      });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });
  }
};

const getAllPost = async (req, res) => {
  try {

    const posts = await Post.find()
      .sort({ createdAt: -1 })
      .populate({ path: "user", select: "-password" })
      .populate({ path: "comments.user", select: "-password" });
    if (posts.length === 0) {
      return res.status(200).json({ message: "No posts found", post: [] });
    }
    res.status(200).json({ posts });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });
  }
};

const getLikedPosts = async (req, res) => {
  const {userId} = req.user;
  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    const likedPosts = await Post.find({ _id: { $in: user.likedPosts } })
      .populate({ path: "user", select: "-password" })
      .populate({ path: "comments.user", select: "-password" });

      res.status(200).json({ posts: likedPosts });
    } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });
  }
};

const getFollowingPosts = async (req, res) => {
  try {
    const {userId} = req.user;
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    const followingUsers = user.following;
    const posts = await Post.find({ user: { $in: followingUsers } })
      .sort({ createdAt: -1 })
      .populate({ path: "user", select: "-password" })
      .populate({ path: "comments.user", select: "-password" });

      res.status(200).json(posts);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });

  }
}

const getUserPost = async (req, res) => {
  try {
    const {username} = req.params;
    const user = await User.findOne({username});
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    const posts = await Post.find({ user: user._id })
      .sort({ createdAt: -1 })
      .populate({ path: "user", select: "-password" })
      .populate({ path: "comments.user", select: "-password" });

    res.status(200).json(posts);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });
  }

}

module.exports = {
  createPost,
  deletePost,
  commentOnPost,
  likeUnLikePost,
  getAllPost,
  getLikedPosts,
  getFollowingPosts,
  getUserPost,
};
