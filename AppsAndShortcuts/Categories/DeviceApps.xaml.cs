using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace AppsAndShortcuts.Categories
{
    /// <summary>
    /// Interaction logic for DeviceApps.xaml
    /// </summary>
    public partial class DeviceApps : Page
    {
        public DeviceApps()
        {
            InitializeComponent();
        }

        private void Device_Properties_Button_Click(object sender, RoutedEventArgs e)
        {
            DeviceAppsFrame.Content = new DeviceAppPages.DeviceProperties();
        }

        private void Credential_Manager_Button_Click(object sender, RoutedEventArgs e)
        {
            DeviceAppsFrame.Content = new DeviceAppPages.CredentialManager();
        }

        private void Skype_For_Business_Button_Click(object sender, RoutedEventArgs e)
        {
            DeviceAppsFrame.Content = new DeviceAppPages.SkypeForBusiness();
        }

        private void Find_a_Computer_Button_Click(object sender, RoutedEventArgs e)
        {
            DeviceAppsFrame.Content = new DeviceAppPages.FindADevice();
        }

        private void Find_a_Printer_Button_Click(object sender, RoutedEventArgs e)
        {
            DeviceAppsFrame.Content = new DeviceAppPages.FindAPrinter();
        }

        private void Office_Quick_Repair_Button_Click(object sender, RoutedEventArgs e)
        {
            DeviceAppsFrame.Content = new DeviceAppPages.OfficeQuickRepair();
        }

        private void Office_Online_Repair_Button_Click(object sender, RoutedEventArgs e)
        {
            DeviceAppsFrame.Content = new DeviceAppPages.OfficeOnlineRepair();

        }

        private void Logged_In_User_Button_Click(object sender, RoutedEventArgs e)
        {
            DeviceAppsFrame.Content = new DeviceAppPages.LoggedInUser();
        }

        private void Check_Watermark_Button_Click(object sender, RoutedEventArgs e)
        {
            DeviceAppsFrame.Content = new DeviceAppPages.CheckWatermark();
        }
    }
}
