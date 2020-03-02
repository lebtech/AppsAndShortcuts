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
    /// Interaction logic for ArcApps.xaml
    /// </summary>
    public partial class ArcApps : Page
    {
        public ArcApps()
        {
            InitializeComponent();
        }

        private void ACL_Finder_Button_Click(object sender, RoutedEventArgs e)
        {
            ArcAppsFrame.Content = new ArcAppPages.AclFinder();
        }

        private void Add_Quick_Fill_Button_Click(object sender, RoutedEventArgs e)
        {
            ArcAppsFrame.Content = new ArcAppPages.AddQuickFill();
        }
    }
}
