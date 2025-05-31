const { getReceiverSocketId, io } = require("../lib/socket");
const Message = require("../models/message.model");
const User = require("../models/user.model");
const cloudinary = require("cloudinary").v2;

const getUsersForSideBar = async (req, res) => {
  try {
    const { userId } = req.user; // Assuming you have userId in req.user after authentication
    const users = await User.find({ _id: { $ne: userId } });
    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
};

const getMessages = async (req, res) => {
  try {
    const { userId } = req.user; // Assuming you have userId in req.user after authentication
    const { id } = req.params; // aaaaaaaaaa??????????? id ng nhan tin
    const messages = await Message.find({
      $or: [
        { senderId: userId, receiverId: id },
        { senderId: id, receiverId: userId },
      ],
    });
    res.status(200).json(messages);
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
};

const sendMessage = async (req, res) => {
  try {
    const { userId } = req.user;
    const { id } = req.params;
    const { text, image } = req.body;

    let imageUrl;
    if (image) {
      const uploadedResponse = await cloudinary.uploader.upload(image);
      imageUrl = uploadedResponse.secure_url;
    }

    const newMessage = new Message({
      senderId: userId,
      receiverId: id,
      text,
      image: imageUrl,
    });

    await newMessage.save();

    const receiverSocketId = getReceiverSocketId(id); // Assuming you have a function to get the receiver's socket ID
    if(receiverSocketId) {
      io.to(receiverSocketId).emit("newMessage", newMessage);
    }
    res.status(201).json(newMessage);
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = {
  getUsersForSideBar,
  getMessages,
  sendMessage,
};
