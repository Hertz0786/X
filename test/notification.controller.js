const Notification = require("../models/notification.model");
const User = require("../models/user.model");

const getNotifications = async (req, res) => {
  try {
    const {userId} = req.user;
    const notifications = await Notification.find({ to: userId }).populate({
      path: "from",
      select: "username profileImg",
    });
    await Notification.updateMany({to: userId}, { read: true });
    res.status(200).json(notifications);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });
  }
};

const deleteNotifications = async (req, res) => {
  try {
    const {userId} = req.user;
    await Notification.deleteMany({ to: userId });
    res.status(200).json({ message: "Notifications deleted successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });
  }
};


module.exports = {
  getNotifications,
  deleteNotifications,
};
